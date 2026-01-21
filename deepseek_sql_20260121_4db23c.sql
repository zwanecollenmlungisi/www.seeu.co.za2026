-- Trigger: Calculate profile completion percentage
CREATE OR REPLACE FUNCTION calculate_profile_score()
RETURNS TRIGGER AS $$
DECLARE
    score INTEGER := 0;
BEGIN
    -- Calculate score based on filled fields
    IF NEW.full_name IS NOT NULL THEN score := score + 10; END IF;
    IF NEW.bio IS NOT NULL THEN score := score + 20; END IF;
    IF NEW.photos IS NOT NULL AND array_length(NEW.photos, 1) >= 1 THEN 
        score := score + (LEAST(array_length(NEW.photos, 1), 8) * 5); 
    END IF;
    IF NEW.age IS NOT NULL THEN score := score + 10; END IF;
    IF NEW.interests IS NOT NULL AND array_length(NEW.interests, 1) >= 1 THEN 
        score := score + 10; 
    END IF;
    IF NEW.video_url IS NOT NULL THEN score := score + 15; END IF;
    
    NEW.profile_score := LEAST(score, 100);
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Add profile_score column first
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS profile_score INTEGER DEFAULT 0;

CREATE TRIGGER update_profile_score
    BEFORE INSERT OR UPDATE ON profiles
    FOR EACH ROW
    EXECUTE FUNCTION calculate_profile_score();