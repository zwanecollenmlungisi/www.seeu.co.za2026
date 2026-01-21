-- List all triggers in your database
SELECT 
    event_object_table as table_name,
    trigger_name,
    event_manipulation as trigger_event,
    action_statement as trigger_body,
    action_timing as trigger_time
FROM information_schema.triggers
WHERE trigger_schema = 'public'
ORDER BY table_name, trigger_name;