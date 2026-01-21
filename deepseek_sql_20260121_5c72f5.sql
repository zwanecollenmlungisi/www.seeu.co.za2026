-- Create admin view for payments
CREATE OR REPLACE VIEW admin_payments_overview AS
SELECT 
    p.full_name,
    p.email,
    p.phone,
    pay.amount,
    pay.currency,
    pay.yoco_payment_id,
    pay.yoco_status,
    pay.yoco_card_brand,
    pay.yoco_card_last4,
    pay.created_at as payment_date,
    p.subscription_end,
    CASE 
        WHEN p.subscription_end > NOW() THEN 'Active'
        ELSE 'Expired'
    END as subscription_status
FROM payments pay
JOIN profiles p ON pay.user_id = p.id
ORDER BY pay.created_at DESC;