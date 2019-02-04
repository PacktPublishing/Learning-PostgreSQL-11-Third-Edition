\pset null null
WITH data (v) as (VALUES (true), (false),(null)) 
    SELECT 
        v::TEXT as a, 
        (NOT v)::TEXT as "NOT a" 
    FROM 
        data
    ORDER BY a DESC nulls last;
