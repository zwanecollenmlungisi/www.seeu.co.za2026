-- Trigger: Create match when mutual likes exist
CREATE OR REPLACE FUNCTION check_and_create_match()
RETURNS TRIGGER AS $$
DECLARE
    reciprocal_like BOOLEAN;
    match_exists BOOLEAN;
BEGIN
    -- Check if reciprocal like exists
    SELECT EXISTS (
        SELECT 1 FROM likes 
        WHERE liker_id = NEW.liked_id 
        AND liked_id = NEW.liker_id
        AND like_type = 'like'
    ) INTO reciprocal_like;
    
    -- Check if match already exists
    SELECT EXISTS (
        SELECT 1 FROM matches 
        WHERE (user1_id = NEW.liker_id AND user2_id = NEW.liked_id)
        OR (user1_id = NEW.liked_id AND user2_id = NEW.liker_id)
    ) INTO match_exists;
    
    -- Create match if reciprocal like exists and no match yet
    IF reciprocal_like AND NEW.like_type = 'like' AND NOT match_exists THEN
        -- Insert match (ensure user1_id < user2_id for consistency)
        INSERT INTO matches (
            user1_id, 
            user2_id, 
            user1_liked, 
            user2_liked,
            matched_at
        ) VALUES (
            LEAST(NEW.liker_id, NEW.liked_id),
            GREATEST(NEW.liker_id, NEW.liked_id),
            CASE WHEN LEAST(NEW.liker_id, NEW.liked_id) = NEW.liker_id THEN TRUE ELSE FALSE END,
            CASE WHEN GREATEST(NEW.liker_id, NEW.liked_id) = NEW.liked_id THEN TRUE ELSE FALSE END,
            NOW()
        )
        ON CONFLICT (user1_id, user2_id) DO NOTHING;
        
        -- Update match counts for both users
        UPDATE profiles 
        SET total_matches = total_matches + 1 
        WHERE id IN (NEW.liker_id, NEW.liked_id);
        
        -- Create initial conversation
        INSERT INTO conversations (
            match_id,
            user1_id,
            user2_id,
            last_message_preview,
            last_message_at
        ) VALUES (
            (SELECT id FROM matches 
             WHERE (user1_id = LEAST(NEW.liker_id, NEW.liked_id) 
                    AND user2_id = GREATEST(NEW.liker_id, NEW.liked_id))),
            NEW.liker_id,
            NEW.liked_id,
            'You matched! Say hello! 👋',
            NOW()
        );
    END IF;
    
    -- Update like counts
    UPDATE profiles 
    SET total_likes = total_likes + 1 
    WHERE id = NEW.liked_id;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER on_like_created
    AFTER INSERT ON likes
    FOR EACH ROW
    EXECUTE FUNCTION check_and_create_match();