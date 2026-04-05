# Bollywood Box Office Analytics Engine

A end-to-end data engineering project built entirely in PostgreSQL.  
Analyzing 214 Bollywood films (2019–2023) to uncover what actually drives box office success.

---

## Key Insights

| Finding | Data |
|---|---|
| Eid releases average ROI | **294%** |
| Diwali releases average ROI | **127%** |
| Films that flopped or were disasters | **61 out of 214** |
| COVID impact (2020 avg ROI) | **80%** |
| Post-COVID recovery (2022 avg ROI) | **276%** |
| Kantara ROI (16cr budget) | **2548%** |
| The Kashmir Files ROI (20cr budget) | **1705%** |

> Small budget films are consistently beating 500cr productions.  
> Star power alone doesn't sell tickets anymore.

---

## Architecture — Star Schema

```
<img width="1104" height="733" alt="{E7BFCBB7-8F26-4A2B-88B2-1321317F2085}" src="https://github.com/user-attachments/assets/a05ef2a2-e644-4a67-b45e-e630c7344491" />

```

**Staging → Dimension Tables → Fact Table**  
Raw CSV data is loaded into a staging table, cleaned using SQL transformations, then loaded into a Star Schema for analytics.

---

## Tech Stack

- **Database:** PostgreSQL
- **Tool:** DBeaver
- **Concepts Used:** Star Schema Design, ETL Pipeline, Window Functions, CTEs, CASE WHEN, Subqueries, JOINs, Query Optimization

---

## Project Structure

```
bollywood-box-office-analytics/
├── README.md
├── data/
│   └── bollywood_raw.csv          # Raw dataset (2019-2023)
├── schema/
│   └── create_tables.sql          # Staging + Star Schema DDL
├── etl/
│   └── load_data.sql              # Data cleaning + loading pipeline
└── analytics/
    └── insights.sql               # All analytical queries
```

---

## How to Run

**Step 1 — Create staging table and import CSV**
```sql
CREATE TABLE stg_bollywood_raw (
    release_date    VARCHAR(20),
    movie           VARCHAR(200),
    worldwide       VARCHAR(50),
    india_hindi_net VARCHAR(50),
    india_gross     VARCHAR(50),
    overseas        VARCHAR(50),
    budget          VARCHAR(50),
    verdict         VARCHAR(50)
);
-- Import bollywood_raw.csv via DBeaver import tool
```

**Step 2 — Create Star Schema**
```sql
-- Run schema/create_tables.sql
```

**Step 3 — Run ETL pipeline**
```sql
-- Run etl/load_data.sql
-- This cleans data, calculates ROI, and loads into Star Schema
```

**Step 4 — Run analytics**
```sql
-- Run analytics/insights.sql
```

---

##  Data Cleaning Decisions

| Issue | Solution |
|---|---|
| Budget = 1 (placeholder) | Filtered out — 124 rows removed |
| Missing worldwide collection | Excluded from ROI calculation |
| Missing verdicts (142 rows) | Recalculated from ROI formula |
| Inconsistent verdict labels | Standardized into 8 tiers |

**ROI Formula:**
```sql
ROI = (worldwide / budget) * 100

> 300% → All Time Blockbuster
> 200% → Blockbuster
> 150% → SuperHit
> 100% → Hit
> 75%  → Average
> 50%  → Flop
else   → Disaster
```

---

## Sample Analytics Queries

**Festive Season Performance:**
```sql
SELECT
    d.festive_season,
    COUNT(*) AS movies,
    ROUND(AVG(f.roi), 2) AS avg_roi,
    ROUND(AVG(f.worldwide), 2) AS avg_collection
FROM fact_movies f
JOIN dim_date d ON f.date_id = d.date_id
GROUP BY d.festive_season
ORDER BY avg_roi DESC;
```

**Top ROI Films:**
```sql
SELECT
    f.movie,
    d.year,
    d.festive_season,
    v.verdict_label,
    f.budget,
    f.worldwide,
    ROUND(f.roi, 2) AS roi
FROM fact_movies f
JOIN dim_date d ON f.date_id = d.date_id
JOIN dim_verdict v ON f.verdict_id = v.verdict_id
ORDER BY f.roi DESC
LIMIT 10;
```

---

## Connect

Built by **@syntaxdsamurai**  
Targeting Data Engineering roles 

---

*Dataset: Bollywood Box Office Collection 2019-2023 (Kaggle)*
