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
    // Get the JWT from the Authorization header
    const authHeader = req.headers.get('Authorization');
    if (!authHeader) {
      return new Response(
        JSON.stringify({ success: false, message: 'Missing authorization header' }),
        { status: 401, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      );
    }
    const jwt = authHeader.replace('Bearer ', '');

    // Create a Supabase client with the service role key
    const supabase = createClient(supabaseUrl, supabaseServiceKey);

    // Get the user from the JWT
    const { data: userData, error: userError } = await supabase.auth.getUser(jwt);
    if (userError || !userData.user) {
      console.error('Failed to get user from JWT:', userError);
      return new Response(
        JSON.stringify({ success: false, message: 'Invalid token' }),
        { status: 401, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      );
    }

    const { token, amountInCents, currency, userId } = await req.json();

    // Check that the userId in the request matches the user ID from the JWT
    if (userData.user.id !== userId) {
      return new Response(
        JSON.stringify({ success: false, message: 'User ID mismatch' }),
        { status: 403, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
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

    // Update the user's profile in Supabase
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