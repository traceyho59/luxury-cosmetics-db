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
-- 2. REVENUE PER FOOTFALL DAY
-- ============================================================================
-- Shows how much revenue is generated per unit of daily footfall

SELECT 
    e.event_id,
    b.brand,
    l.city,
    (e.units_sold * p.price_usd) / NULLIF(e.avg_daily_footfall, 0) 
        AS revenue_per_footfall
FROM events e
JOIN products p ON e.sku = p.sku
JOIN brands b ON e.brand_id = b.brand_id
JOIN locations l ON e.location_id = l.location_id
ORDER BY revenue_per_footfall DESC;

-- ============================================================================
-- 3. REVENUE PER LEASE DAY
-- ============================================================================
-- Shows daily revenue generation efficiency

SELECT 
    e.event_id,
    b.brand,
    l.city,
    (e.units_sold * p.price_usd) / NULLIF(e.lease_length_days, 0)
        AS revenue_per_lease_day
FROM events e
JOIN products p ON e.sku = p.sku
JOIN brands b ON e.brand_id = b.brand_id
JOIN locations l ON e.location_id = l.location_id
ORDER BY revenue_per_lease_day DESC;

-- ============================================================================
-- 4. REVENUE PER LEASE DAY BY LOCATION (AGGREGATED)
-- ============================================================================
-- Aggregates revenue efficiency at the city level for bubble map visualization

SELECT 
    l.city,
    r.region,
    COUNT(e.event_id) AS total_events,
    SUM(e.units_sold * p.price_usd) AS total_revenue,
    SUM(e.lease_length_days) AS total_lease_days,
    SUM(e.units_sold * p.price_usd) 
        / NULLIF(SUM(e.lease_length_days), 0) AS revenue_per_lease_day
FROM events e
JOIN products p ON e.sku = p.sku
JOIN locations l ON e.location_id = l.location_id
JOIN regions r ON l.region_id = r.region_id
GROUP BY l.city, r.region
ORDER BY revenue_per_lease_day DESC;

-- ============================================================================
-- 5. REVENUE EFFICIENCY BY REGION (AGGREGATED)
-- ============================================================================
-- Regional-level aggregation for geographic trend analysis

SELECT 
    r.region,
    COUNT(e.event_id) AS total_events,
    SUM(e.units_sold * p.price_usd) AS total_revenue,
    SUM(e.avg_daily_footfall * e.lease_length_days) AS total_visitor_days,
    SUM(e.units_sold * p.price_usd) 
        / NULLIF(SUM(e.avg_daily_footfall * e.lease_length_days), 0) 
        AS revenue_efficiency_per_visitor_day
FROM events e
JOIN products p ON e.sku = p.sku
JOIN locations l ON e.location_id = l.location_id
JOIN regions r ON l.region_id = r.region_id
GROUP BY r.region
ORDER BY revenue_efficiency_per_visitor_day DESC;

-- ============================================================================
-- 6. SCATTERPLOT DATA: REVENUE PER FOOTFALL VS REVENUE PER LEASE DAY
-- ============================================================================
-- Provides data for scatterplot visualization comparing two efficiency metrics

SELECT 
    e.event_id,
    b.brand,
    l.city,
    r.region,
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
JOIN regions r ON l.region_id = r.region_id;

-- ============================================================================
-- 7. TOP 20 MOST EFFICIENT EVENTS
-- ============================================================================
-- Quick view of best performing events by revenue efficiency

SELECT 
    e.event_id,
    b.brand,
    l.city,
    r.region,
    et.event_type,
    lt.location_type,
    (e.units_sold * p.price_usd) AS total_revenue,
    e.avg_daily_footfall,
    e.lease_length_days,
    ROUND(
        (e.units_sold * p.price_usd)::numeric 
        / NULLIF((e.avg_daily_footfall * e.lease_length_days), 0), 
        4
    ) AS revenue_efficiency
FROM events e
JOIN products p ON e.sku = p.sku
JOIN brands b ON e.brand_id = b.brand_id
JOIN locations l ON e.location_id = l.location_id
JOIN regions r ON l.region_id = r.region_id
JOIN event_types et ON e.event_type_id = et.event_type_id
JOIN location_types lt ON e.location_type_id = lt.location_type_id
ORDER BY revenue_efficiency DESC
LIMIT 20;
