# Set secrets for your Edge Function
supabase secrets set YOCO_SECRET_KEY=sk_test_your_yoco_secret_key
supabase secrets set SUPABASE_URL=https://your-project-ref.supabase.co
supabase secrets set SUPABASE_SERVICE_ROLE_KEY=your-service-role-key-here

# Deploy the function
supabase functions deploy process-yoco-payment --no-verify-jwt