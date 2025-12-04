-- ================================================================================
-- 8. BRAND PARTICIPATION ACROSS REGIONS AND FORMATS (AGGREGATED)
-- ================================================================================
SELECT
    b.brand,
    COUNT(DISTINCT l.region_id) AS regions_active,
    COUNT(DISTINCT e.event_type_id) AS formats_used,
    COUNT(e.event_id) AS total_events,
    ROUND(AVG(e.sell_through_pct), 4) AS avg_sell_through,
    ROUND(AVG(e.sales_conversion_rate), 4) AS avg_conversion,
    SUM(e.units_sold) AS total_units_sold,
    ROUND(STDDEV(e.sell_through_pct), 4) AS performance_variability,
    ROUND(MIN(e.sell_through_pct), 4) AS worst_sell_through,
    ROUND(MAX(e.sell_through_pct), 4) AS best_sell_through,
    CASE 
        WHEN AVG(e.sell_through_pct) >= 0.76 THEN 'Top Tier'
        WHEN AVG(e.sell_through_pct) >= 0.73 THEN 'High Performer'
        WHEN AVG(e.sell_through_pct) >= 0.70 THEN 'Above Average'
        ELSE 'Average'
    END AS performance_tier,
    CASE 
        WHEN COUNT(DISTINCT l.region_id) >= 4 AND COUNT(DISTINCT e.event_type_id) >= 4 THEN 'Highly Diversified'
        WHEN COUNT(DISTINCT l.region_id) >= 3 OR COUNT(DISTINCT e.event_type_id) >= 3 THEN 'Moderately Diversified'
        ELSE 'Focused Strategy'
    END AS diversification_level
FROM events e
    JOIN brands b ON e.brand_id = b.brand_id
    JOIN locations l ON e.location_id = l.location_id
GROUP BY b.brand
ORDER BY avg_sell_through DESC, total_events DESC;