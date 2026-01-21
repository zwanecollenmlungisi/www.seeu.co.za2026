-- Trigger: Check for expired matches
CREATE OR REPLACE FUNCTION check_match_expiration()
RETURNS TRIGGER AS $$
BEGIN
    -- If match is older than 24 hours and no messages, mark as inactive
    IF NEW.last_message_at IS NULL 
       AND NEW.matched_at < NOW() - INTERVAL '24 hours' 
       AND NEW.status = 'matched' THEN
        
        NEW.status := 'expired';
        
        -- Notify users
        INSERT INTO notifications (user_id, type, title, message, created_at)
        SELECT user1_id, 'match_expired', 'Match Expired', 'Your match has expired', NOW()
        FROM matches WHERE id = NEW.id
        UNION ALL
        SELECT user2_id, 'match_expired', 'Match Expired', 'Your match has expired', NOW()
        FROM matches WHERE id = NEW.id;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Run this on a schedule or add to update trigger