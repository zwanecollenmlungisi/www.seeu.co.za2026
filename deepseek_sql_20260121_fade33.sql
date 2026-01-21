-- Trigger: Track user visits/views
CREATE OR REPLACE FUNCTION track_profile_view()
RETURNS TRIGGER AS $$
BEGIN
    -- Check if view exists in last 24 hours
    IF NOT EXISTS (
        SELECT 1 FROM visits 
        WHERE viewer_id = NEW.viewer_id 
        AND viewed_id = NEW.viewed_id 
        AND last_viewed_at > NOW() - INTERVAL '24 hours'
    ) THEN
        -- Update view count on profile
        UPDATE profiles 
        SET total_views = total_views + 1 
        WHERE id = NEW.viewed_id;
        
        -- Send notification for unique views
        INSERT INTO notifications (
            user_id,
            type,
            title,
            message,
            related_id,
            created_at
        ) VALUES (
            NEW.viewed_id,
            'profile_view',
            'Someone viewed your profile',
            'Your profile was viewed recently',
            NEW.viewer_id,
            NOW()
        );
    END IF;
    
    -- Update last_viewed_at
    NEW.last_viewed_at = NOW();
    NEW.view_count = COALESCE((
        SELECT view_count FROM visits 
        WHERE viewer_id = NEW.viewer_id AND viewed_id = NEW.viewed_id
    ), 0) + 1;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER on_profile_view
    BEFORE INSERT OR UPDATE ON visits
    FOR EACH ROW
    EXECUTE FUNCTION track_profile_view();