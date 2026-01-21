-- Trigger: When payment is successful, update user status
CREATE OR REPLACE FUNCTION handle_payment_success()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.status = 'completed' AND OLD.status != 'completed' THEN
        -- Update user profile to premium
        UPDATE profiles 
        SET 
            payment_status = 'paid',
            payment_date = NEW.created_at,
            subscription_start = NEW.created_at,
            subscription_end = NEW.created_at + INTERVAL '1 year',
            verified = TRUE
        WHERE id = NEW.user_id;
        
        -- Send welcome email (you'd integrate with email service)
        PERFORM pg_notify('new_premium_user', 
            json_build_object(
                'user_id', NEW.user_id,
                'email', (SELECT email FROM profiles WHERE id = NEW.user_id),
                'payment_id', NEW.id
            )::text
        );
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER on_payment_completed
    AFTER UPDATE ON payments
    FOR EACH ROW
    WHEN (OLD.status IS DISTINCT FROM NEW.status)
    EXECUTE FUNCTION handle_payment_success();