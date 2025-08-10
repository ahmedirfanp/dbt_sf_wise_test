SELECT
    experience,
    platform,
    region,
    COUNT(*) AS created_transfers,
    COUNT(CASE WHEN funded_date IS NOT NULL THEN 1 END) AS funded_transfers,
    COUNT(CASE WHEN transferred_date IS NOT NULL THEN 1 END) AS completed_transfers,
    
    ROUND(
        COUNT(CASE WHEN funded_date IS NOT NULL THEN 1 END) * 100.0 /
        COUNT(*), 2
    ) AS created_to_funded_pct,
    
    ROUND(
        COUNT(CASE WHEN transferred_date IS NOT NULL THEN 1 END) * 100.0 /
        NULLIF(COUNT(CASE WHEN funded_date IS NOT NULL THEN 1 END), 0), 2
    ) AS funded_to_completed_pct,
    
    ROUND(
        COUNT(CASE WHEN transferred_date IS NOT NULL THEN 1 END) * 100.0 /
        COUNT(*), 2
    ) AS created_to_completed_pct

FROM {{ ref('count_days') }}
GROUP BY experience, platform, region
ORDER BY experience, platform, region