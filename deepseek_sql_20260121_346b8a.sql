-- Create performance log table
CREATE TABLE IF NOT EXISTS trigger_performance (
    id SERIAL PRIMARY KEY,
    trigger_name TEXT NOT NULL,
    execution_time_ms INTEGER,
    rows_affected INTEGER,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Example of timed trigger
CREATE OR REPLACE FUNCTION timed_trigger_function()
RETURNS TRIGGER AS $$
DECLARE
    start_time TIMESTAMP;
    end_time TIMESTAMP;
BEGIN
    start_time := clock_timestamp();
    
    -- Your trigger logic here
    
    end_time := clock_timestamp();
    
    INSERT INTO trigger_performance (
        trigger_name,
        execution_time_ms,
        rows_affected
    ) VALUES (
        TG_NAME,
        EXTRACT(MILLISECONDS FROM (end_time - start_time)),
        TG_NARGS
    );
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;