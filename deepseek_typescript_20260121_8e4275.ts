// ... existing imports ...
import { verify } from 'https://deno.land/x/djwt@v2.9.1/mod.ts';

const supabaseUrl = Deno.env.get('SUPABASE_URL')!;
const supabaseServiceKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!;
const jwtSecret = Deno.env.get('JWT_SECRET')!; // We need to set this secret

Deno.serve(async (req) => {
  // ... CORS headers ...

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

    // Verify the JWT and extract the user ID
    let payload;
    try {
      payload = await verify(jwt, jwtSecret, 'HS256');
    } catch (err) {
      console.error('JWT verification failed:', err);
      return new Response(
        JSON.stringify({ success: false, message: 'Invalid token' }),
        { status: 401, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      );
    }

    const { token, amountInCents, currency, userId } = await req.json();

    // Check that the userId in the request matches the JWT's sub (user id)
    if (payload.sub !== userId) {
      return new Response(
        JSON.stringify({ success: false, message: 'User ID mismatch' }),
        { status: 403, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      );
    }

    // ... rest of the function (Yoco charge and update database) ...
  } catch (error) {
    // ... error handling ...
  }
});