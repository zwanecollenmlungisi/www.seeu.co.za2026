-- Trigger: When business feature is enabled/disabled
CREATE OR REPLACE FUNCTION handle_business_toggle()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.business_enabled = TRUE AND OLD.business_enabled = FALSE THEN
        -- Validate business info when enabling
        IF NEW.business_name IS NULL OR NEW.business_description IS NULL THEN
            RAISE EXCEPTION 'Business name and description are required when enabling business feature';
        END IF;
        
        -- Log business feature activation
        INSERT INTO feature_usage (
            user_id,
            feature,
            action,
            created_at
        ) VALUES (
            NEW.id,
            'business_profile',
            'enabled',
            NOW()
        );
        
    ELSIF NEW.business_enabled = FALSE AND OLD.business_enabled = TRUE THEN
        -- Log deactivation
        INSERT INTO feature_usage (
            user_id,
            feature,
            action,
            created_at
        ) VALUES (
            NEW.id,
            'business_profile',
            'disabled',
            NOW()
        );
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER on_business_toggle
    BEFORE UPDATE ON profiles
    FOR EACH ROW
    WHEN (OLD.business_enabled IS DISTINCT FROM NEW.business_enabled)
    EXECUTE FUNCTION handle_business_toggle();