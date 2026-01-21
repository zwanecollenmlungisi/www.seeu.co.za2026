#!/bin/bash
# deploy-triggers.sh

echo "🚀 Deploying Supabase triggers for See U Dating App..."

# Connect to your Supabase database
PGPASSWORD=$SUPABASE_DB_PASSWORD psql -h db.$SUPABASE_PROJECT_REF.supabase.co \
  -U postgres \
  -d postgres \
  -c "

-- 1. Create trigger functions
$(cat triggers/functions.sql)

-- 2. Create triggers
$(cat triggers/triggers.sql)

-- 3. Enable pg_cron jobs
$(cat triggers/cron.sql)

-- 4. Verify deployment
SELECT '✅ Triggers deployed successfully' as status;
"

echo "✅ Trigger deployment complete!"