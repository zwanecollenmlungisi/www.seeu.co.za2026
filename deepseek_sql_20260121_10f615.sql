-- Trigger: Boost premium users in discovery algorithm
CREATE OR REPLACE FUNCTION update_discovery_score()
RETURNS TRIGGER AS $$
BEGIN
    -- Recalculate discovery score when profile changes
    NEW.discovery_score := 
        CASE 
            WHEN NEW.payment_status = 'paid' THEN 100
            ELSE 50 
        END +
        CASE 
            WHEN NEW.profile_score >= 80 THEN 30
            WHEN NEW.profile_score >= 50 THEN 15
            ELSE 0 
        END +
        CASE 
            WHEN NEW.last_active > NOW() - INTERVAL '7 days' THEN 20
            ELSE 0 
        END;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER calculate_discovery_score
    BEFORE INSERT OR UPDATE ON profiles
    FOR EACH ROW
    EXECUTE FUNCTION update_discovery_score();