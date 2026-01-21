-- Ensure payments table exists
CREATE TABLE IF NOT EXISTS payments (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  amount DECIMAL(10,2) NOT NULL,
  currency TEXT DEFAULT 'ZAR',
  yoco_payment_id TEXT UNIQUE,
  yoco_status TEXT,
  yoco_card_brand TEXT,
  yoco_card_last4 TEXT,
  yoco_card_exp_month TEXT,
  yoco_card_exp_year TEXT,
  status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'completed', 'failed', 'refunded')),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create indexes
CREATE INDEX idx_payments_user ON payments(user_id);
CREATE INDEX idx_payments_yoco_id ON payments(yoco_payment_id);

-- Add RLS policies
ALTER TABLE payments ENABLE ROW LEVEL SECURITY;

-- Users can view their own payments
CREATE POLICY "Users can view own payments" ON payments
  FOR SELECT USING (auth.uid() = user_id);

-- Only service role can insert payments (via Edge Function)
CREATE POLICY "Service role can insert payments" ON payments
  FOR INSERT WITH CHECK (auth.role() = 'service_role');

-- Update profiles table if needed
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS subscription_start TIMESTAMPTZ;
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS subscription_end TIMESTAMPTZ;
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS subscription_plan TEXT DEFAULT 'annual';
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS subscription_amount DECIMAL(10,2) DEFAULT 289.99;

-- Create function to update subscription dates
CREATE OR REPLACE FUNCTION update_subscription_dates()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.payment_status = 'paid' AND OLD.payment_status != 'paid' THEN
        NEW.subscription_start = NOW();
        NEW.subscription_end = NOW() + INTERVAL '1 year';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger
DROP TRIGGER IF EXISTS on_payment_status_change ON profiles;
CREATE TRIGGER on_payment_status_change
    BEFORE UPDATE ON profiles
    FOR EACH ROW
    EXECUTE FUNCTION update_subscription_dates();