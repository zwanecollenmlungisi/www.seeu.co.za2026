-- Enable pg_cron extension
CREATE EXTENSION IF NOT EXISTS pg_cron;

-- Schedule daily cleanup of expired matches
SELECT cron.schedule(
    'cleanup-expired-matches',
    '0 3 * * *', -- Every day at 3 AM
    $$
    UPDATE matches 
    SET status = 'expired'
    WHERE status = 'matched' 
    AND last_message_at IS NULL 
    AND matched_at < NOW() - INTERVAL '24 hours';
    $$
);

-- Schedule weekly analytics update
SELECT cron.schedule(
    'update-analytics',
    '0 4 * * 1', -- Every Monday at 4 AM
    $$
    INSERT INTO analytics_weekly (
        week_start,
        total_users,
        new_users,
        total_matches,
        messages_sent,
        revenue
    )
    SELECT 
        DATE_TRUNC('week', NOW() - INTERVAL '1 week') as week_start,
        COUNT(*) as total_users,
        COUNT(*) FILTER (WHERE created_at >= NOW() - INTERVAL '1 week') as new_users,
        (SELECT COUNT(*) FROM matches WHERE matched_at >= NOW() - INTERVAL '1 week'),
        (SELECT COUNT(*) FROM messages WHERE created_at >= NOW() - INTERVAL '1 week'),
        (SELECT COALESCE(SUM(amount), 0) FROM payments 
         WHERE created_at >= NOW() - INTERVAL '1 week' AND status = 'completed')
    FROM profiles;
    $$
);