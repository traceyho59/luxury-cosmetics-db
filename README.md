# Luxury Cosmetics Pop-Up Events Database

A relational database system for analyzing luxury cosmetics pop-up retail events, built as part of Columbia University's APAN 5310 (SQL & Relational Databases) course.

## Project Overview

This project implements a normalized (3NF) PostgreSQL database to track and analyze pop-up retail events for luxury cosmetics brands across global markets. The system supports three core business objectives:

1. **Revenue Efficiency Analysis** - Evaluate event performance relative to footfall and lease duration
2. **Brand Performance Tracking** - MIdentifying and tracking high-performing brands, locations, and event types based on sell-through rates, conversion efficiency, and regional participation patterns

## Database Schema

The database follows Third Normal Form (3NF) with 8 tables:

| Table | Description |
|-------|-------------|
| `regions` | Geographic regions (North America, Europe, Asia, etc.) |
| `locations` | City-level location data with region references |
| `location_types` | Venue categories (Mall, Airport Duty-Free, High-Street, etc.) |
| `event_types` | Event formats (Flash Event, Standalone Pop-Up, etc.) |
| `brands` | Brand information with parent company relationships |
| `product_categories` | Product classification (Lip Products, Eye Products, etc.) |
| `products` | Individual SKUs with pricing |
| `events` | Central fact table with event metrics and foreign keys |

![ER Diagram](ER_diagram.png)

## Repository Structure

```
├── sql/
│   ├── 01_schema_and_data.sql      # DDL + full data insert
│   ├── 02_business_req_1.sql       # Revenue efficiency queries
│   ├── 03_business_req_2_rates.sql       # High performer identification
│   ├── 04_business_req_2_kpis.sql  # KPI summary queries
│   ├── 05_business_req_2_region.sql    # Regional brand analysis
│   └── 06_business_req_2_brand.sql     # Brand participation analysis
├── notebooks/
│   └── etl_and_analysis.ipynb      # Python ETL + query execution
├── diagrams/
│   └── ER_diagram.png              # Entity-Relationship diagram
├── docs/
│   └── business_requirements.md    # Detailed business requirements
├── requirements.txt
└── README.md
```

## Key Metrics

| Metric | Value |
|--------|-------|
| Total Events | 2,133 |
| Total Units Sold | 4,132,484 |
| Participating Brands | 24 |
| Active Regions | 4 |
| Event Formats | 5 |
| Overall Sell-Through Rate | 73.23% |

## Tech Stack

- **Database**: PostgreSQL
- **ETL**: Python (pandas, SQLAlchemy)
- **Administration**: pgAdmin 4
- **Visualization**: Metabase (planned)

## Getting Started

### Prerequisites

- PostgreSQL 14+
- Python 3.9+
- pgAdmin 4 (optional)

### Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/YOUR_USERNAME/luxury-cosmetics-db.git
   cd luxury-cosmetics-db
   ```

2. Install Python dependencies:
   ```bash
   pip install -r requirements.txt
   ```

3. Create the database and load schema/data:
   ```bash
   psql -U postgres -c "CREATE DATABASE luxury_cosmetics;"
   psql -U postgres -d luxury_cosmetics -f sql/01_schema_and_data.sql
   ```

4. Run business requirement queries:
   ```bash
   psql -U postgres -d luxury_cosmetics -f sql/02_business_req_1.sql
   ```

### Using the Python Notebook

1. Update the connection string in `notebooks/etl_and_analysis.ipynb`:
   ```python
   conn_url = 'postgresql://postgres:YOUR_PASSWORD@localhost/luxury_cosmetics'
   ```

2. Launch Jupyter:
   ```bash
   jupyter notebook notebooks/etl_and_analysis.ipynb
   ```

## Business Requirements

### BR#1: Revenue Efficiency

Calculates revenue efficiency at both event and location levels:
- Revenue per visitor-day = Total Revenue / (Avg Daily Footfall × Lease Days)
- Revenue per lease day by location
- Supports bar charts and bubble maps for visualization

### BR#2: High-Performer Identification

Identifies optimal combinations of event types and location types:
- Performance matrix with uplift calculations vs. global/regional averages
- Tier classification (Excellent, Good, Average, Needs Improvement)
- R² analysis to determine relative importance of event type vs. location type

### BR#3: Brand Performance Tracking

Comprehensive brand analytics:
- KPI scorecard with key metrics
- Brand performance benchmarking with tier classification
- Regional dominance analysis
- Event format preferences by brand
- Versatility scoring (multi-format, multi-region success)
- Market opportunity identification

## Sample Queries

**Top 10 Cities by Sell-Through Rate:**
```sql
SELECT l.city, r.region,
       COUNT(e.event_id) as total_events,
       ROUND(AVG(e.sell_through_pct), 4) as avg_sell_through
FROM events e
    JOIN locations l ON e.location_id = l.location_id
    JOIN regions r ON l.region_id = r.region_id
GROUP BY l.city, r.region
HAVING COUNT(e.event_id) >= 5
ORDER BY avg_sell_through DESC
LIMIT 10;
```

**Brand Performance Summary:**
```sql
SELECT b.brand,
       COUNT(e.event_id) AS total_events,
       ROUND(AVG(e.sell_through_pct), 4) AS avg_sell_through,
       CASE 
           WHEN AVG(e.sell_through_pct) >= 0.76 THEN 'Top Tier'
           WHEN AVG(e.sell_through_pct) >= 0.73 THEN 'High Performer'
           ELSE 'Average'
       END AS performance_tier
FROM events e
    JOIN brands b ON e.brand_id = b.brand_id
GROUP BY b.brand
ORDER BY avg_sell_through DESC;
```

## Authors

APAN 5310 Project Team - Columbia University:
Tracey Ho,
Samantha Yung,
Ellen Li,
Alessia Laziosi,
Michael Yan,
Poorva Desai

## License

This project is for educational purposes as part of Columbia University coursework.
