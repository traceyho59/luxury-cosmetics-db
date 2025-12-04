-- ============================================================================
-- BUSINESS REQUIREMENT #1: REVENUE EFFICIENCY ANALYSIS
-- ============================================================================
-- Analyzing revenue efficiency to evaluate event performance relative to 
-- footfall and lease duration
-- ============================================================================

-- ============================================================================
-- 1. EVENT LEVEL REVENUE EFFICIENCY SCORE
-- ============================================================================
-- Calculates revenue efficiency per visitor day for each event
-- Formula: Total Revenue / (Avg Daily Footfall × Lease Length Days)

SELECT 
    e.event_id,
    b.brand,
    l.city,
    p.product_name,
    (e.units_sold * p.price_usd) AS total_revenue,
    e.avg_daily_footfall,
    e.lease_length_days,

    (e.units_sold * p.price_usd) 
        / NULLIF((e.avg_daily_footfall * e.lease_length_days), 0) 
        AS revenue_efficiency_per_visitor_day
FROM events e
JOIN products p ON e.sku = p.sku
JOIN brands b ON e.brand_id = b.brand_id
JOIN locations l ON e.location_id = l.location_id
ORDER BY revenue_efficiency_per_visitor_day DESC;

-- ============================================================================
-- 2. City level revenue efficiency
-- ============================================================================

SELECT 
    l.city,
    AVG(
        (e.units_sold * p.price_usd) / NULLIF((e.avg_daily_footfall * e.lease_length_days), 0)
    ) AS avg_revenue_efficiency
FROM events e
JOIN products p ON e.sku = p.sku
JOIN locations l ON e.location_id = l.location_id
GROUP BY l.city
ORDER BY avg_revenue_efficiency DESC;

-- ============================================================================
-- 3. Revenue per footfall day
-- ============================================================================

SELECT 
    event_id,
    (units_sold * price_usd) / NULLIF(avg_daily_footfall, 0) 
        AS revenue_per_footfall
FROM events
JOIN products USING (sku)
ORDER BY revenue_per_footfall DESC;

-- ============================================================================
-- 4. Revenue per lease day
-- ============================================================================

SELECT 
    e.event_id,
    (e.units_sold * p.price_usd) / NULLIF(e.lease_length_days, 0)
        AS revenue_per_lease_day
FROM events e
JOIN products p ON e.sku = p.sku
ORDER BY revenue_per_lease_day DESC;

-- ============================================================================
-- 5. Event level Revenue efficiency
-- ============================================================================

SELECT 
    e.event_id,
    et.event_type,
    (e.units_sold * p.price_usd) 
        / NULLIF((e.avg_daily_footfall * e.lease_length_days), 0)
        AS revenue_efficiency_per_visitor_day
FROM events e
JOIN products p ON e.sku = p.sku
JOIN event_types et ON e.event_type_id = et.event_type_id
ORDER BY revenue_efficiency_per_visitor_day DESC;

-- ============================================================================
-- 6. Revenue per lease day by Location
-- ============================================================================
-- Provides data for scatterplot visualization comparing two efficiency metrics

SELECT 
    l.city,
    SUM(e.units_sold * p.price_usd) AS total_revenue,
    SUM(e.lease_length_days) AS total_lease_days,
    SUM(e.units_sold * p.price_usd) 
        / NULLIF(SUM(e.lease_length_days), 0) AS revenue_per_lease_day
FROM events e
JOIN products p ON e.sku = p.sku
JOIN locations l ON e.location_id = l.location_id
GROUP BY l.city
ORDER BY revenue_per_lease_day DESC;

-- ============================================================================
-- 7. Revenue generated compared to lease day
-- ============================================================================

SELECT 
    e.event_id,
    b.brand,
    l.city,
    (e.units_sold * p.price_usd) / NULLIF(e.avg_daily_footfall, 0)
        AS x_revenue_per_footfall,
    (e.units_sold * p.price_usd) / NULLIF(e.lease_length_days, 0)
        AS y_revenue_per_lease_day,
    (e.units_sold * p.price_usd) AS total_revenue,
    e.avg_daily_footfall,
    e.lease_length_days
FROM events e
JOIN products p ON e.sku = p.sku
JOIN brands b ON e.brand_id = b.brand_id
JOIN locations l ON e.location_id = l.location_id

-- ============================================================================
-- 8. Show total revenue generated compared to number of lease days
-- ============================================================================

SELECT 
    l.city,
    SUM(e.units_sold * p.price_usd) AS total_revenue,
    SUM(e.lease_length_days) AS total_lease_days,
    SUM(e.units_sold * p.price_usd) 
        / NULLIF(SUM(e.lease_length_days), 0) AS revenue_per_lease_day
FROM events e
JOIN products p ON e.sku = p.sku
JOIN locations l ON e.location_id = l.location_id
GROUP BY l.city
ORDER BY revenue_per_lease_day DESC;

-- ============================================================================
-- 9. Event performance summary by city
-- ============================================================================

WITH event_summary AS (
    SELECT
        l.city,
        e.event_id,
        et.event_type,
        e.avg_daily_footfall,
        e.lease_length_days,
        (e.units_sold * p.price_usd) AS total_revenue,
        (e.units_sold * p.price_usd) 
            / NULLIF((e.avg_daily_footfall * e.lease_length_days), 0)
            AS revenue_efficiency_per_visitor_day
    FROM events e
    JOIN products p ON e.sku = p.sku
    JOIN locations l ON e.location_id = l.location_id
    JOIN event_types et ON e.event_type_id = et.event_type_id
),

city_agg AS (
    SELECT
        city,
        COUNT(event_id) AS total_events,
        AVG(avg_daily_footfall) AS avg_footfall,
        AVG(lease_length_days) AS avg_lease_length,
        SUM(total_revenue) AS total_revenue_city,
        AVG(revenue_efficiency_per_visitor_day) AS avg_efficiency_city
    FROM event_summary
    GROUP BY city
),

city_ranking AS (
    SELECT
        city,
        total_events,
        avg_footfall,
        avg_lease_length,
        total_revenue_city,
        avg_efficiency_city,
        RANK() OVER (ORDER BY avg_efficiency_city DESC) AS efficiency_rank
    FROM city_agg
)

SELECT *
FROM city_ranking
ORDER BY efficiency_rank;
