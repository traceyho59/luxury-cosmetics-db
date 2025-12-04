-- ================================================================================
-- 1. BRAND PERFORMANCE BENCHMARKING (MORE GRANULAR TIERS)
-- ================================================================================
SELECT
    b.brand,
    COUNT(e.event_id) AS total_events,
    ROUND(AVG(e.sell_through_pct), 4) AS avg_sell_through,
    ROUND(AVG(e.sales_conversion_rate), 4) AS avg_conversion,
    SUM(e.units_sold) AS total_units_sold,
    CASE 
        WHEN AVG(e.sell_through_pct) >= 0.76 THEN 'Top Tier Performer'
        WHEN AVG(e.sell_through_pct) >= 0.73 THEN 'High Performer'
        WHEN AVG(e.sell_through_pct) >= 0.70 THEN 'Above Average'
        WHEN AVG(e.sell_through_pct) >= 0.65 THEN 'Average Performer'
        ELSE 'Below Average'
    END AS performance_tier,
    CASE 
        WHEN COUNT(e.event_id) >= 100 THEN 'High Volume Brand'
        WHEN COUNT(e.event_id) >= 70 THEN 'Medium Volume Brand'
        ELSE 'Low Volume Brand'
    END AS activity_level
FROM events e
    JOIN brands b ON e.brand_id = b.brand_id
GROUP BY b.brand
ORDER BY avg_sell_through DESC, total_events DESC;

-- ================================================================================
-- 2. REGIONAL BRAND DOMINANCE
-- ================================================================================
SELECT
    r.region,
    b.brand,
    COUNT(e.event_id) AS events_in_region,
    ROUND(AVG(e.sell_through_pct), 4) AS avg_sell_through,
    ROUND(AVG(e.sales_conversion_rate), 4) AS avg_conversion,
    SUM(e.units_sold) AS total_units_sold,
    ROUND(COUNT(e.event_id) * 100.0 / SUM(COUNT(e.event_id)) OVER (PARTITION BY r.region), 2) AS pct_of_regional_events
FROM events e
    JOIN brands b ON e.brand_id = b.brand_id
    JOIN locations l ON e.location_id = l.location_id
    JOIN regions r ON l.region_id = r.region_id
GROUP BY r.region, b.brand
HAVING COUNT(e.event_id) >= 10
ORDER BY r.region, events_in_region DESC;

-- ================================================================================
-- 3. EVENT FORMAT PREFERENCE BY BRAND
-- ================================================================================
SELECT
    b.brand,
    et.event_type,
    COUNT(e.event_id) AS events_count,
    ROUND(AVG(e.sell_through_pct), 4) AS avg_sell_through,
    ROUND(AVG(e.sales_conversion_rate), 4) AS avg_conversion,
    SUM(e.units_sold) AS total_units_sold,
    ROUND(COUNT(e.event_id) * 100.0 / SUM(COUNT(e.event_id)) OVER (PARTITION BY b.brand), 2) AS pct_of_brand_events
FROM events e
    JOIN brands b ON e.brand_id = b.brand_id
    JOIN event_types et ON e.event_type_id = et.event_type_id
GROUP BY b.brand, et.event_type
HAVING COUNT(e.event_id) >= 5
ORDER BY b.brand, events_count DESC;

-- ================================================================================
-- 4. CONVERSION RATE LEADERS BY REGION
-- ================================================================================
SELECT
    r.region,
    b.brand,
    COUNT(e.event_id) AS total_events,
    ROUND(AVG(e.sell_through_pct), 4) AS avg_sell_through,
    ROUND(AVG(e.sales_conversion_rate), 4) AS avg_conversion,
    SUM(e.units_sold) AS total_units_sold,
    RANK() OVER (PARTITION BY r.region ORDER BY AVG(e.sales_conversion_rate) DESC) AS conversion_rank
FROM events e
    JOIN brands b ON e.brand_id = b.brand_id
    JOIN locations l ON e.location_id = l.location_id
    JOIN regions r ON l.region_id = r.region_id
GROUP BY r.region, b.brand
HAVING COUNT(e.event_id) >= 5
ORDER BY r.region, conversion_rank;

-- ================================================================================
-- 5. MOST VERSATILE BRANDS (MULTI-FORMAT SUCCESS)
-- ================================================================================
SELECT
    b.brand,
    COUNT(DISTINCT e.event_type_id) AS formats_used,
    COUNT(DISTINCT l.region_id) AS regions_active,
    COUNT(e.event_id) AS total_events,
    ROUND(AVG(e.sell_through_pct), 4) AS avg_sell_through,
    ROUND(MIN(e.sell_through_pct), 4) AS min_sell_through,
    ROUND(MAX(e.sell_through_pct), 4) AS max_sell_through,
    ROUND(STDDEV(e.sell_through_pct), 4) AS performance_consistency,
    CASE 
        WHEN STDDEV(e.sell_through_pct) <= 0.15 THEN 'Highly Consistent'
        WHEN STDDEV(e.sell_through_pct) <= 0.25 THEN 'Moderately Consistent'
        ELSE 'Variable Performance'
    END AS consistency_rating
FROM events e
    JOIN brands b ON e.brand_id = b.brand_id
    JOIN locations l ON e.location_id = l.location_id
GROUP BY b.brand
HAVING COUNT(DISTINCT e.event_type_id) >= 3
ORDER BY formats_used DESC, avg_sell_through DESC;

-- ================================================================================
-- 6. UNDERUTILIZED REGIONS (OPPORTUNITY ANALYSIS)
-- ================================================================================
SELECT
    r.region,
    COUNT(DISTINCT e.brand_id) AS active_brands,
    COUNT(e.event_id) AS total_events,
    ROUND(AVG(e.sell_through_pct), 4) AS avg_sell_through,
    ROUND(AVG(e.sales_conversion_rate), 4) AS avg_conversion,
    24 - COUNT(DISTINCT e.brand_id) AS missing_brands,
    CASE 
        WHEN COUNT(DISTINCT e.brand_id) >= 20 THEN 'Saturated Market'
        WHEN COUNT(DISTINCT e.brand_id) >= 15 THEN 'Developed Market'
        ELSE 'Growth Opportunity'
    END AS market_maturity
FROM events e
    JOIN locations l ON e.location_id = l.location_id
    JOIN regions r ON l.region_id = r.region_id
GROUP BY r.region
ORDER BY missing_brands DESC, avg_sell_through DESC;

-- ================================================================================
-- 7. HIGH-PERFORMING FORMAT-REGION COMBINATIONS
-- ================================================================================
SELECT
    r.region,
    et.event_type,
    COUNT(e.event_id) AS total_events,
    COUNT(DISTINCT e.brand_id) AS brands_participating,
    ROUND(AVG(e.sell_through_pct), 4) AS avg_sell_through,
    ROUND(AVG(e.sales_conversion_rate), 4) AS avg_conversion,
    SUM(e.units_sold) AS total_units_sold,
    CASE 
        WHEN AVG(e.sell_through_pct) >= 0.75 AND COUNT(e.event_id) >= 20 THEN 'Proven Winner'
        WHEN AVG(e.sell_through_pct) >= 0.70 THEN 'Strong Performer'
        ELSE 'Needs Improvement'
    END AS combo_rating
FROM events e
    JOIN locations l ON e.location_id = l.location_id
    JOIN regions r ON l.region_id = r.region_id
    JOIN event_types et ON e.event_type_id = et.event_type_id
GROUP BY r.region, et.event_type
HAVING COUNT(e.event_id) >= 10
ORDER BY avg_sell_through DESC, total_events DESC;