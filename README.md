# E-Commerce Customer & Sales Analytics

An end-to-end business analytics project: a synthetic but realistic e-commerce dataset, a full SQL +
Python analysis, and an interactive white/blue dashboard — built as a **business case study**, not
just a dashboard. See **[`CASE_STUDY.md`](CASE_STUDY.md)** for the findings and recommendations, or
open **[`dashboard/dashboard.html`](dashboard/dashboard.html)** directly in a browser to explore the
numbers yourself.

## What this is

5,000 customers, 31,332 orders, 57,801 order line items across 10 categories, 5 acquisition channels,
and 3 shipping tiers, spanning Jan 2023 – Aug 2026. The data is generated (`01_generate_data.py`) with
deliberate, realistic business mechanics baked in — margin falls as discount rises, Apparel/Footwear
carry more return risk than Electronics, Paid Social converts more one-time buyers than Referral — so
that the analysis below is a genuine "discovery," not a lookup of numbers I already knew.

**Business questions answered:** monthly/weekly revenue trends, revenue & margin by category, AOV;
new vs. returning customers, CLV, RFM segmentation, repeat-purchase rate; monthly cohort retention,
churn; discount impact on margin, acquisition channel performance & CAC; return rate, high-return
products, delivery performance.

## Tech stack

| Tool | What it's used for |
|---|---|
| **SQL** (SQLite) | Primary analysis layer — schema + 20 queries across 5 topic files |
| **Python** (pandas, numpy, matplotlib) | Deeper analysis, RFM scoring, cohort matrix, charts — `analysis/ecommerce_analysis.ipynb` |
| **Dashboard** (HTML/CSS/JS + Chart.js) | Interactive white/blue dashboard, no server required |
| **Excel** | Initial data-cleaning demonstration (`excel/data_cleaning_demo.xlsx`) |

**Deliberately not used:** PostgreSQL + Docker. The schema and every query are ~95% Postgres-portable
(see the dialect notes in `sql/01_schema.sql`), but this project ships a working SQLite database with
zero setup instead of standing up a container for a portfolio piece — a scoping call, not a shortcut.
Power BI was the original spec's dashboard tool; since generating a native `.pbix` file isn't possible
here, the dashboard is a self-contained interactive HTML file instead, styled to the same white/blue
brief and readable directly in any browser without installing anything.

## Folder structure

```
ecommerce-analytics/
├── data/                      Source-of-truth CSVs + a ready-to-query SQLite database
│   ├── customers.csv, products.csv, orders.csv, order_items.csv, returns.csv, marketing_spend.csv
│   └── ecommerce.db           Built from sql/01_schema.sql — open with any SQLite client
├── sql/                       20 queries across 5 files, plus the schema
│   ├── 01_schema.sql
│   ├── 02_revenue_analysis.sql
│   ├── 03_customer_rfm_clv.sql
│   ├── 04_retention_cohort_churn.sql
│   ├── 05_marketing_discount_channel.sql
│   └── 06_operations_returns_delivery.sql
├── analysis/
│   ├── ecommerce_analysis.ipynb    Full Python analysis, executed with real output + charts
│   ├── analysis_source.py          Same analysis as a plain script (source of the notebook)
│   ├── charts/                     PNG exports of every chart in the notebook
│   └── results_summary.json        Every headline number, machine-readable
├── dashboard/
│   └── dashboard.html          Interactive dashboard — open directly in a browser
├── excel/
│   └── data_cleaning_demo.xlsx Raw → cleaned sample showing the initial-cleaning step
├── CASE_STUDY.md               Findings & recommendations (the "so what")
└── README.md                   This file
```

## How to run it

**Dashboard:** open `dashboard/dashboard.html` in any browser. No build step, no server.

**SQL:** `data/ecommerce.db` is a ready-to-query SQLite database.
```bash
sqlite3 data/ecommerce.db < sql/02_revenue_analysis.sql
```
Or open it with any SQLite GUI (DB Browser for SQLite, TablePlus, etc.) and run the files in `sql/`
directly. To rebuild it from scratch: `01_generate_data.py` regenerates the CSVs, then loads them
into a fresh `ecommerce.db` using `sql/01_schema.sql`.

**Notebook:**
```bash
pip install pandas numpy matplotlib
jupyter notebook analysis/ecommerce_analysis.ipynb
```
The shipped `.ipynb` already contains full output and charts — no need to re-run it to see the results,
only to reproduce or extend them.

## Key findings (full detail in [`CASE_STUDY.md`](CASE_STUDY.md))

- Returning customers drive **84% of revenue**; the top 40% of customers by RFM score (Champions +
  Loyal) drive **77.5%** of it.
- Orders discounted 26–40% run **26.9 margin points below full-price orders** (57% relatively lower).
- Paid Social costs **7.5x more per customer** than Organic Search and delivers **38% lower LTV**
  than Referral.
- Apparel & Footwear return at roughly **2x the platform average**, driven mainly by fit.
- Significantly delayed deliveries return at **6.55% vs. 4.94%** for on-time orders.
