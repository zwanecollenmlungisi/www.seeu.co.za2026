# Deploy the Edge Function
supabase functions deploy process-yoco-payment

# Tail logs to see real-time errors
supabase functions tail process-yoco-payment

# Invoke function directly for testing
curl -X POST https://your-project-ref.supabase.co/functions/v1/process-yoco-payment \
  -H "Authorization: Bearer user-jwt-token" \
  -H "Content-Type: application/json" \
  -d '{
    "token": "tok_test_valid_token",
    "amountInCents": 28999,
    "userId": "user-uuid",
    "userEmail": "test@example.com"
  }'

# Check database records
psql "postgresql://postgres:[password]@db.[project-ref].supabase.co:5432/postgres" \
  -c "SELECT * FROM payments ORDER BY created_at DESC LIMIT 5;"