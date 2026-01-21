// Follow this setup guide to integrate the Deno runtime with Supabase Edge Functions: https://supabase.com/docs/guides/functions

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
    return new Response(null, { headers: corsHeaders });
  }

  try {
    const { token, amountInCents, currency, userId } = await req.json();

    // Validate input
    if (!token || !amountInCents || !currency || !userId) {
      return new Response(
        JSON.stringify({ success: false, message: 'Missing required fields' }),
        { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      );
    }

    // Charge the card via Yoco
    const yocoResponse = await fetch('https://payments.yoco.com/api/charges', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${YOCO_SECRET_KEY}`,
      },
      body: JSON.stringify({
        token,
        amountInCents,
        currency,
      }),
    });

    const yocoData = await yocoResponse.json();

    if (!yocoResponse.ok) {
      console.error('Yoco charge failed:', yocoData);
      return new Response(
        JSON.stringify({ success: false, message: yocoData.error.message || 'Payment failed' }),
        { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      );
    }

    // If the charge is successful, update the user's profile in Supabase
    const supabase = createClient(supabaseUrl, supabaseServiceKey);

    const { error: updateError } = await supabase
      .from('profiles')
      .update({
        payment_status: 'paid',
        payment_date: new Date().toISOString(),
        subscription_end: new Date(Date.now() + 365 * 24 * 60 * 60 * 1000).toISOString(),
      })
      .eq('id', userId);

    if (updateError) {
      console.error('Failed to update user profile:', updateError);
      // We don't want to return an error here because the payment was successful, but we should log it and maybe handle it manually.
      // However, for now, we'll just send a success response but note the update failure.
      return new Response(
        JSON.stringify({ 
          success: true, 
          chargeId: yocoData.id, 
          message: 'Payment successful but user profile update failed. Please contact support.' 
        }),
        { headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      );
    }

    return new Response(
      JSON.stringify({ success: true, chargeId: yocoData.id }),
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
