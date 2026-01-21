-- Create error log table
CREATE TABLE IF NOT EXISTS trigger_errors (
    id SERIAL PRIMARY KEY,
    trigger_name TEXT NOT NULL,
    table_name TEXT NOT NULL,
    error_message TEXT,
    row_data JSONB,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Modify any trigger function to log errors
CREATE OR REPLACE FUNCTION safe_trigger_function()
RETURNS TRIGGER AS $$
BEGIN
    BEGIN
        -- Your trigger logic here
        RETURN NEW;
    EXCEPTION WHEN OTHERS THEN
        INSERT INTO trigger_errors (
            trigger_name,
            table_name,
            error_message,
            row_data
        ) VALUES (
            TG_NAME,
            TG_TABLE_NAME,
            SQLERRM,
            row_to_json(NEW)
        );
        RETURN NULL; -- Suppress error from bubbling up
    END;
END;
$$ LANGUAGE plpgsql;