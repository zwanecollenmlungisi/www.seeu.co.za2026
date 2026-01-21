// supabase/functions/process-yoco-payment/index.ts

import "https://deno.land/x/xhr@0.1.0/mod.ts";
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2.39.0';

const YOCO_SECRET_KEY = Deno.env.get('YOCO_SECRET_KEY')!;
const supabaseUrl = Deno.env.get('SUPABASE_URL')!;
const supabaseServiceKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!;

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
};

Deno.serve(async (req) => {
  // Handle CORS preflight requests
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders });
  }

  try {
    const { token, amountInCents, userId, userEmail } = await req.json();

    // Validate input
    if (!token || !amountInCents || !userId) {
      return new Response(
        JSON.stringify({ success: false, message: 'Missing required fields' }),
        { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      );
    }

    // 1. Charge the card via Yoco API
    const yocoResponse = await fetch('https://payments.yoco.com/api/charges', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${YOCO_SECRET_KEY}`,
      },
      body: JSON.stringify({
        token,
        amountInCents,
        currency: 'ZAR',
      }),
    });

    const yocoData = await yocoResponse.json();

    if (!yocoResponse.ok) {
      console.error('Yoco charge failed:', yocoData);
      return new Response(
        JSON.stringify({ 
          success: false, 
          message: yocoData.error?.message || 'Payment failed' 
        }),
        { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      );
    }

    // 2. Create Supabase client with service role key (bypasses RLS)
    const supabase = createClient(supabaseUrl, supabaseServiceKey);

    // 3. Create payment record in payments table
    const { data: paymentData, error: paymentError } = await supabase
      .from('payments')
      .insert({
        user_id: userId,
        amount: amountInCents / 100, // Convert cents to Rands
        currency: 'ZAR',
        yoco_payment_id: yocoData.id,
        yoco_status: yocoData.status,
        yoco_card_brand: yocoData.source?.brand,
        yoco_card_last4: yocoData.source?.last4,
        status: 'completed'
      })
      .select()
      .single();

    if (paymentError) {
      console.error('Failed to create payment record:', paymentError);
      // Continue anyway - payment succeeded but record failed
    }

    // 4. Update user's profile to paid status
    const subscriptionEnd = new Date();
    subscriptionEnd.setFullYear(subscriptionEnd.getFullYear() + 1); // 1 year from now

    const { error: profileError } = await supabase
      .from('profiles')
      .update({
        payment_status: 'paid',
        payment_date: new Date().toISOString(),
        subscription_start: new Date().toISOString(),
        subscription_end: subscriptionEnd.toISOString(),
        subscription_plan: 'annual',
        subscription_amount: 289.99
      })
      .eq('id', userId);

    if (profileError) {
      console.error('Failed to update user profile:', profileError);
      return new Response(
        JSON.stringify({ 
          success: true, 
          chargeId: yocoData.id, 
          warning: 'Payment successful but user profile update failed. Please contact support.' 
        }),
        { headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      );
    }

    // 5. Return success response
    return new Response(
      JSON.stringify({ 
        success: true, 
        chargeId: yocoData.id,
        paymentId: paymentData?.id
      }),
      { headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    );

  } catch (error) {
    console.error('Error processing payment:', error);
    return new Response(
      JSON.stringify({ success: false, message: 'Internal server error' }),
      { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    );
  }
});