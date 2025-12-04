-- ================================================================================
-- 8. KEY PERFORMANCE INDICATORS (KPI) SUMMARY
-- ================================================================================
SELECT 'Overall Sell-Through Rate' AS metric, 
    ROUND(AVG(e.sell_through_pct), 4)::TEXT AS value
FROM events e

UNION ALL

SELECT 'Overall Conversion Rate' AS metric, 
    ROUND(AVG(e.sales_conversion_rate), 4)::TEXT AS value
FROM events e

UNION ALL

SELECT 'Total Events' AS metric, 
    COUNT(e.event_id)::TEXT AS value
FROM events e

UNION ALL

SELECT 'Total Units Sold' AS metric, 
    SUM(e.units_sold)::TEXT AS value
FROM events e

UNION ALL

SELECT 'Total Brands Participating' AS metric, 
    COUNT(DISTINCT e.brand_id)::TEXT AS value
FROM events e

UNION ALL

SELECT 'Total Regions Active' AS metric, 
    COUNT(DISTINCT l.region_id)::TEXT AS value
FROM events e
    JOIN locations l ON e.location_id = l.location_id

UNION ALL

SELECT 'Total Event Formats Used' AS metric, 
    COUNT(DISTINCT e.event_type_id)::TEXT AS value
FROM events e

UNION ALL

SELECT 'High Performers (>80% Sell-Through)' AS metric, 
    COUNT(e.event_id)::TEXT AS value
FROM events e
WHERE e.sell_through_pct >= 0.80

UNION ALL

SELECT 'Best Performing Region' AS metric, 
    sub.region AS value
FROM (
    SELECT r.region, AVG(e.sell_through_pct) AS avg_st
    FROM events e
        JOIN locations l ON e.location_id = l.location_id
        JOIN regions r ON l.region_id = r.region_id
    GROUP BY r.region
    ORDER BY avg_st DESC
    LIMIT 1
) sub

UNION ALL

SELECT 'Best Performing Event Format' AS metric, 
    sub.event_type AS value
FROM (
    SELECT et.event_type, AVG(e.sell_through_pct) AS avg_st
    FROM events e
        JOIN event_types et ON e.event_type_id = et.event_type_id
    GROUP BY et.event_type
    ORDER BY avg_st DESC
    LIMIT 1
) sub

UNION ALL

SELECT 'Best Performing Brand' AS metric, 
    sub.brand AS value
FROM (
    SELECT b.brand, AVG(e.sell_through_pct) AS avg_st
    FROM events e
        JOIN brands b ON e.brand_id = b.brand_id
    GROUP BY b.brand
    ORDER BY avg_st DESC
    LIMIT 1
) sub

UNION ALL

SELECT 'Average Event Duration (Days)' AS metric, 
    ROUND(AVG(e.lease_length_days), 1)::TEXT AS value
FROM events e

UNION ALL

SELECT 'Average Daily Footfall' AS metric, 
    ROUND(AVG(e.avg_daily_footfall), 0)::TEXT AS value
FROM events e;