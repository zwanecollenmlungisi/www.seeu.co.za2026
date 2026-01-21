-- Trigger: When messages are marked as read, update conversation
CREATE OR REPLACE FUNCTION handle_message_read()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.read = TRUE AND OLD.read = FALSE THEN
        -- Decrease unread count in conversation
        UPDATE conversations 
        SET unread_count = GREATEST(0, unread_count - 1)
        WHERE match_id = NEW.match_id;
        
        -- Decrease unread count in match
        UPDATE matches 
        SET unread_count = GREATEST(0, unread_count - 1)
        WHERE id = NEW.match_id;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER on_message_read
    AFTER UPDATE ON messages
    FOR EACH ROW
    WHEN (OLD.read IS DISTINCT FROM NEW.read)
    EXECUTE FUNCTION handle_message_read();