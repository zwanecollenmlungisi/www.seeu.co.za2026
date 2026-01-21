-- Monitor trigger execution
SELECT 
    trigger_name,
    COUNT(*) as executions,
    AVG(execution_time_ms) as avg_time_ms,
    MAX(execution_time_ms) as max_time_ms,
    MIN(created_at) as first_run,
    MAX(created_at) as last_run
FROM trigger_performance
WHERE created_at > NOW() - INTERVAL '7 days'
GROUP BY trigger_name
ORDER BY executions DESC;