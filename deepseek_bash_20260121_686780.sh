# Deploy all triggers at once
supabase db push

# View trigger logs in real-time
supabase logs --follow

# Test a specific trigger
psql "postgresql://postgres:[password]@db.[project-ref].supabase.co:5432/postgres" \
  -c "INSERT INTO likes (liker_id, liked_id, like_type) VALUES ('user1', 'user2', 'like');"

# Backup trigger definitions
pg_dump -h db.$SUPABASE_PROJECT_REF.supabase.co \
  -U postgres \
  -d postgres \
  --schema-only \
  --table='*triggers*' \
  > triggers_backup.sql