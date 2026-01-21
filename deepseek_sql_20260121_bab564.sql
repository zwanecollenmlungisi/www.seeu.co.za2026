-- Trigger: Ensure users are 18+
CREATE OR REPLACE FUNCTION verify_user_age()
RETURNS TRIGGER AS $$
BEGIN
    -- Check if age is provided and valid
    IF NEW.age IS NOT NULL THEN
        IF NEW.age < 18 THEN
            RAISE EXCEPTION 'Users must be 18 years or older';
        END IF;
        
        IF NEW.age > 100 THEN
            RAISE EXCEPTION 'Please enter a valid age';
        END IF;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER enforce_age_requirement
    BEFORE INSERT OR UPDATE ON profiles
    FOR EACH ROW
    EXECUTE FUNCTION verify_user_age();