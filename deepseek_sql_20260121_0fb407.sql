-- Archive old notifications
CREATE OR REPLACE FUNCTION archive_old_notifications()
RETURNS void AS $$
BEGIN
    INSERT INTO notifications_archive
    SELECT * FROM notifications 
    WHERE created_at < NOW() - INTERVAL '90 days';
    
    DELETE FROM notifications 
    WHERE created_at < NOW() - INTERVAL '90 days';
END;
$$ LANGUAGE plpgsql;

-- Schedule with cron
SELECT cron.schedule(
    'archive-notifications',
    '0 2 * * *', -- Daily at 2 AM
    'SELECT archive_old_notifications();'
);