-- ============================================================================
-- 1.1 Cities ranked by average sell-through rate (CORRECTED)
-- ============================================================================
SELECT 
    l.city,
    r.region,
    COUNT(e.event_id) as total_events,
    ROUND(AVG(e.sell_through_pct), 4) as avg_sell_through,
    ROUND(AVG(e.sales_conversion_rate), 4) as avg_conversion,
    SUM(e.units_sold) as total_units_sold,
    ROUND(AVG(e.units_sold), 0) as avg_units_per_event
FROM events e
    JOIN locations l ON e.location_id = l.location_id
    JOIN regions r ON l.region_id = r.region_id
GROUP BY l.city, r.region
HAVING COUNT(e.event_id) >= 5  -- Only cities with meaningful sample size
ORDER BY avg_sell_through DESC
LIMIT 10;

-- ============================================================================
-- 1.2 Regions ranked by performance
-- ============================================================================
SELECT 
    r.region,
    COUNT(DISTINCT l.location_id) as locations_count,
    COUNT(e.event_id) as total_events,
    ROUND(AVG(e.sell_through_pct), 4) as avg_sell_through,
    ROUND(AVG(e.sales_conversion_rate), 4) as avg_conversion,
    SUM(e.units_sold) as total_units_sold,
    ROUND(SUM(e.units_sold * p.price_usd), 2) as total_revenue_usd
FROM events e
    JOIN locations l ON e.location_id = l.location_id
    JOIN regions r ON l.region_id = r.region_id
    JOIN products p ON e.sku = p.sku
GROUP BY r.region
ORDER BY avg_sell_through DESC;

-- ============================================================================
-- 2. TOP PERFORMING LOCATION TYPES
-- ============================================================================
SELECT 
    lt.location_type,
    COUNT(e.event_id) as total_events,
    ROUND(AVG(e.sell_through_pct), 4) as avg_sell_through,
    ROUND(AVG(e.sales_conversion_rate), 4) as avg_conversion,
    ROUND(STDDEV(e.sell_through_pct), 4) as sell_through_stddev,
    MIN(e.sell_through_pct) as min_sell_through,
    MAX(e.sell_through_pct) as max_sell_through,
    SUM(e.units_sold) as total_units_sold,
    ROUND(AVG(e.avg_daily_footfall), 0) as avg_footfall
FROM events e
    JOIN location_types lt ON e.location_type_id = lt.location_type_id
GROUP BY lt.location_type
ORDER BY avg_sell_through DESC;

-- ============================================================================
-- 3. TOP PERFORMING EVENT TYPES
-- ============================================================================
SELECT 
    et.event_type,
    COUNT(e.event_id) as total_events,
    ROUND(AVG(e.sell_through_pct), 4) as avg_sell_through,
    ROUND(AVG(e.sales_conversion_rate), 4) as avg_conversion,
    ROUND(AVG(e.lease_length_days), 1) as avg_lease_days,
    ROUND(AVG(e.units_sold::numeric / e.lease_length_days), 2) as avg_daily_units_sold,
    SUM(e.units_sold) as total_units_sold
FROM events e
    JOIN event_types et ON e.event_type_id = et.event_type_id
GROUP BY et.event_type
ORDER BY avg_sell_through DESC;

-- ============================================================================
-- 4. BEST PERFORMING COMBINATIONS
-- ============================================================================
SELECT 
    l.city,
    r.region,
    lt.location_type,
    et.event_type,
    COUNT(e.event_id) as events,
    ROUND(AVG(e.sell_through_pct), 4) as avg_sell_through,
    ROUND(AVG(e.sales_conversion_rate), 4) as avg_conversion,
    SUM(e.units_sold) as total_units,
    ROUND(AVG(e.units_sold), 0) as avg_units
FROM events e
    JOIN locations l ON e.location_id = l.location_id
    JOIN regions r ON l.region_id = r.region_id
    JOIN location_types lt ON e.location_type_id = lt.location_type_id
    JOIN event_types et ON e.event_type_id = et.event_type_id
GROUP BY l.city, r.region, lt.location_type, et.event_type
HAVING COUNT(e.event_id) >= 3
ORDER BY avg_sell_through DESC
LIMIT 20;

-- ============================================================================
-- 5. BRAND PERFORMANCE BY REGION
-- ============================================================================
SELECT 
    b.brand,
    b.parent_company,
    r.region,
    COUNT(e.event_id) as events,
    ROUND(AVG(e.sell_through_pct), 4) as avg_sell_through,
    ROUND(AVG(e.sales_conversion_rate), 4) as avg_conversion,
    SUM(e.units_sold) as total_units_sold
FROM events e
    JOIN brands b ON e.brand_id = b.brand_id
    JOIN locations l ON e.location_id = l.location_id
    JOIN regions r ON l.region_id = r.region_id
GROUP BY b.brand, b.parent_company, r.region
ORDER BY b.brand, avg_sell_through DESC;

-- ============================================================================
-- 6. LOCATION TYPE + EVENT TYPE PERFORMANCE MATRIX
-- ============================================================================
SELECT 
    lt.location_type,
    et.event_type,
    COUNT(e.event_id) as event_count,
    ROUND(AVG(e.sell_through_pct), 4) as avg_sell_through,
    ROUND(AVG(e.sales_conversion_rate), 4) as avg_conversion,
    ROUND(AVG(e.units_sold), 0) as avg_units_sold,
    CASE 
        WHEN AVG(e.sell_through_pct) >= 0.90 THEN 'EXCELLENT'
        WHEN AVG(e.sell_through_pct) >= 0.80 THEN 'GOOD'
        WHEN AVG(e.sell_through_pct) >= 0.70 THEN 'AVERAGE'
        ELSE 'NEEDS IMPROVEMENT'
    END as performance_tier
FROM events e
    JOIN location_types lt ON e.location_type_id = lt.location_type_id
    JOIN event_types et ON e.event_type_id = et.event_type_id
GROUP BY lt.location_type, et.event_type
HAVING COUNT(e.event_id) >= 5
ORDER BY avg_sell_through DESC;

-- ============================================================================
-- 7. HIGH PERFORMER IDENTIFICATION
-- ============================================================================
WITH location_performance AS (
    SELECT 
        l.location_id,
        l.city,
        r.region,
        COUNT(e.event_id) as event_count,
        AVG(e.sell_through_pct) as avg_sell_through,
        AVG(e.sales_conversion_rate) as avg_conversion,
        MIN(e.sell_through_pct) as worst_performance,
        MAX(e.sell_through_pct) as best_performance
    FROM events e
        JOIN locations l ON e.location_id = l.location_id
        JOIN regions r ON l.region_id = r.region_id
    GROUP BY l.location_id, l.city, r.region
    HAVING COUNT(e.event_id) >= 5
)
SELECT 
    city,
    region,
    event_count,
    ROUND(avg_sell_through, 4) as avg_sell_through,
    ROUND(avg_conversion, 4) as avg_conversion,
    ROUND(worst_performance, 4) as min_sell_through,
    ROUND(best_performance, 4) as max_sell_through,
    CASE 
        WHEN avg_sell_through >= 0.90 AND worst_performance >= 0.80 THEN 'TIER 1 - Consistent High Performer'
        WHEN avg_sell_through >= 0.90 THEN 'TIER 2 - High Average, Some Variability'
        WHEN avg_sell_through >= 0.85 THEN 'TIER 3 - Good Performance'
        ELSE 'TIER 4 - Needs Improvement'
    END as location_tier
FROM location_performance
ORDER BY avg_sell_through DESC
LIMIT 15;

-- ============================================================================
-- 8. EXECUTIVE SUMMARY VIEW
-- ============================================================================
WITH best_location_type AS (
    SELECT 
        lt.location_type,
        AVG(e.sell_through_pct) as avg_performance
    FROM events e
    JOIN location_types lt ON e.location_type_id = lt.location_type_id
    GROUP BY lt.location_type
    ORDER BY avg_performance DESC
    LIMIT 1
)
SELECT 'Overall Performance' as metric, ROUND(AVG(sell_through_pct), 4)::TEXT as value
FROM events
UNION ALL
SELECT 'Total Events', COUNT(*)::TEXT FROM events
UNION ALL
SELECT 'Total Units Sold', SUM(units_sold)::TEXT FROM events
UNION ALL
SELECT 'High Performers (>90%)', COUNT(*)::TEXT FROM events WHERE sell_through_pct > 0.90
UNION ALL
SELECT 'Best Location Type', location_type FROM best_location_type;