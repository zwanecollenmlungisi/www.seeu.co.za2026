-- Trigger: Suspend users inactive for 90 days
CREATE OR REPLACE FUNCTION suspend_inactive_users()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.last_active < NOW() - INTERVAL '90 days' 
       AND NEW.suspended = FALSE 
       AND NEW.payment_status = 'paid' THEN
        
        NEW.suspended := TRUE;
        NEW.suspension_reason := 'Inactivity';
        
        -- Refund prorated amount if on paid plan
        -- (You'd implement your refund logic here)
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER check_user_inactivity
    BEFORE UPDATE ON profiles
    FOR EACH ROW
    WHEN (OLD.last_active IS DISTINCT FROM NEW.last_active)
    EXECUTE FUNCTION suspend_inactive_users();