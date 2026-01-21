-- Trigger: Update conversation when new message sent
CREATE OR REPLACE FUNCTION handle_new_message()
RETURNS TRIGGER AS $$
BEGIN
    -- Update match's last message info
    UPDATE matches 
    SET 
        last_message_at = NEW.created_at,
        last_message_preview = SUBSTRING(NEW.message_text FROM 1 FOR 50),
        unread_count = CASE 
            WHEN NEW.receiver_id = user1_id OR NEW.receiver_id = user2_id 
            THEN unread_count + 1 
            ELSE unread_count 
        END
    WHERE (user1_id = NEW.sender_id AND user2_id = NEW.receiver_id)
       OR (user1_id = NEW.receiver_id AND user2_id = NEW.sender_id);
    
    -- Update conversation
    UPDATE conversations 
    SET 
        last_message_preview = SUBSTRING(NEW.message_text FROM 1 FOR 50),
        last_message_at = NEW.created_at,
        unread_count = unread_count + 1,
        updated_at = NOW()
    WHERE match_id = NEW.match_id;
    
    -- Update user's last_active timestamp
    UPDATE profiles 
    SET last_active = NOW() 
    WHERE id = NEW.sender_id;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER on_message_sent
    AFTER INSERT ON messages
    FOR EACH ROW
    EXECUTE FUNCTION handle_new_message();