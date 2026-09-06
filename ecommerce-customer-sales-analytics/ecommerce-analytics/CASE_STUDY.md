# E-Commerce Customer & Sales Analytics — Business Case Study

**Dataset:** 5,000 customers · 31,332 orders · 57,801 order line items · Jan 2023 – Aug 2026
**Stack:** SQL (schema + 20 queries) · Python (pandas/numpy analysis, `analysis/ecommerce_analysis.ipynb`) · interactive dashboard (`dashboard/dashboard.html`) · Excel (initial cleaning demo)

This is a synthetic dataset generated for this project, built with realistic, internally consistent
business mechanics (e.g., margin mechanically falls as discount rises; Apparel/Footwear carry higher
return risk than Electronics or Grocery; Paid Social converts more one-time buyers than Referral).
Every number below comes directly from `analysis/ecommerce_analysis.ipynb` — nothing here is invented
independently of that notebook, and the SQL scripts in `sql/` reproduce the same figures.

---

## 1. Revenue

**Headline numbers:** $9.72M total net revenue · 31,332 orders · $310.17 AOV · 41.9% overall margin.
Revenue grew from ~$54K/month in Jan 2023 to a peak of $335K in Dec 2025, with a consistent Nov/Dec
holiday lift every year.

Furniture ($3.11M) and Electronics ($1.89M) are the two largest categories by revenue, but they also
carry the platform's thinnest margins (40.4% and 30.8% respectively) — driven by higher unit costs
relative to price. Beauty & Personal Care and Apparel & Clothing sell far less volume but run the
richest margins (58.7% and 54.4%).

> **Finding:** Electronics and Furniture generate ~51% of total revenue but only ~35% of total profit,
> because their margins run 10–15 points below the platform average.
>
> **Recommendation:** Revenue targets for Furniture/Electronics should be paired with a margin floor,
> not tracked on revenue alone — a $1 sale in Apparel is worth roughly 1.8x the profit of a $1 sale in
> Electronics.

---

## 2. Customers — Value & Segmentation

Returning customers (2nd order or later) generate **84.0%** of net revenue, vs. 16.0% from first-time
orders — the customer base, not new acquisition, carries the business. Average historical CLV is
**$1,943.62**, and the repeat-purchase rate is **75.84%**.

RFM segmentation (Recency/Frequency/Monetary, quintile-scored) splits customers into six groups:

| Segment | % of customers | % of revenue | Avg CLV |
|---|---|---|---|
| Loyal Customers | 22.3% | 40.4% | $3,522 |
| Champions | 17.7% | 37.1% | $4,070 |
| Need Attention | 19.4% | 9.9% | $993 |
| Hibernating | 19.2% | 4.4% | $446 |
| At Risk | 7.5% | 4.7% | $1,231 |
| New / Promising | 13.9% | 3.5% | $485 |

> **Finding:** Champions + Loyal Customers are **40% of the customer base but drive 77.5% of revenue** —
> a textbook Pareto pattern. At the other end, Hibernating + New/Promising customers are **33%** of the
> base and contribute under **8%** of revenue; most are one-and-done buyers who never returned
> (one-time buyers make up ~25% of all customers by design of the underlying purchase behavior).
>
> **Recommendation:** Two distinct plays, not one blended strategy — (1) a loyalty/VIP tier for
> Champions/Loyal Customers to protect the 77.5% of revenue concentrated there, and (2) a
> second-purchase incentive (time-boxed discount or free shipping on order #2) aimed specifically at
> first-time buyers, since converting even 10–15% of one-time buyers into repeat customers would move
> real revenue given how large that segment is.

---

## 3. Retention — Cohorts & Churn

Monthly cohort retention (mature cohorts, acquired by Dec 2025) averages **33.8%** still active in
month 1, dropping gradually to **28.6%** by month 6 — most of the drop-off happens in the first month,
then the curve flattens, meaning customers who survive past month 1 are reasonably durable.

> **Finding:** 180-day churn stands at **68.94%** — high in absolute terms, but consistent with a
> customer base where a quarter of all customers only ever place one order. The month-1 cliff (100% →
> 33.8%) is the single largest drop in the entire retention curve.
>
> **Recommendation:** Retention efforts are more efficient aimed at the 0–30 day window than at
> "at risk" customers six months out — a post-purchase email/SMS sequence in the first 30 days is
> where the largest share of preventable churn sits.

---

## 4. Marketing — Discounting & Acquisition Channels

**This is the headline finding for the whole project.** Grouping order line items by the discount
applied to their order:

| Discount band | Net revenue | Avg profit margin |
|---|---|---|
| 0% (full price) | $4.70M | 46.89% |
| 1–10% | $2.51M | 43.79% |
| 11–25% | $1.74M | 35.15% |
| 26–40% | $0.76M | 20.03% |

> **Finding:** Orders discounted 26–40% run at **20.03% margin vs. 46.89% for full-price orders — a
> 26.9-point gap (57% relatively lower)** — while contributing only 7.9% of total revenue. The margin
> decline is steady and almost linear across every band, meaning there's no "safe" discount threshold;
> every additional discount point costs real margin.
>
> **Recommendation:** Reserve discounts above 25% for specific, targeted use cases — winning back
> At-Risk high-LTV customers, or clearing slow-moving inventory — rather than broad promotional
> campaigns, and avoid stacking deep discounts on already low-margin categories (Electronics,
> Furniture) where there's little margin left to give up.

Acquisition channel performance tells a complementary story:

| Channel | Avg LTV | CAC | LTV:CAC | % one-and-done |
|---|---|---|---|---|
| Referral | $2,353 | $55 | 42.5x | 14.3% |
| Organic Search | $2,148 | $41 | 52.2x | 20.6% |
| Direct | $2,026 | n/a (unpaid) | n/a | 22.4% |
| Email Marketing | $1,942 | $72 | 27.1x | 23.0% |
| Paid Social | $1,448 | $309 | 4.7x | 34.6% |

> **Finding:** Paid Social costs **7.5x more per acquired customer than Organic Search** ($309 vs.
> $41 CAC) and delivers **38% lower average LTV** than Referral, with more than double the one-and-done
> rate of Referral (34.6% vs. 14.3%). It's still LTV:CAC-positive (4.7x), just far weaker than every
> other channel.
>
> **Recommendation:** Shift incremental budget from Paid Social toward a formal referral program and
> organic/SEO investment — both are already outperforming on efficiency without needing new spend to
> prove it out.

---

## 5. Operations — Returns & Delivery

Overall return rate is **5.03%**, but it's very unevenly distributed:

| Category | Return rate |
|---|---|
| Apparel & Clothing | 10.93% |
| Footwear | 10.19% |
| Furniture | 7.24% |
| *(platform average)* | *5.03%* |
| Grocery & Gourmet | 1.03% |

The five highest-return individual products (min. 40 units sold) are all Apparel or Footwear items —
Denim Jacket Deluxe (17.8%), Cotton T-Shirt Deluxe (16.8%), Chino Shorts Max (16.8%), Dress Shoes
Classic (16.2%), and Wool Sweater Classic (15.7%).

Delivery: Standard shipping has both the longest average delivery time (6.53 days) and the highest
significant-delay rate (7.1% of orders arrive more than 3 days late), vs. 4.6% for Express and 2.5%
for Same-Day.

> **Finding:** Apparel & Clothing and Footwear return at roughly **2x the platform average**, driven
> almost entirely by fit rather than defects. Separately, **significantly delayed orders return at
> 6.55% vs. 4.94% for on-time orders** — a real, if moderate, link between fulfillment delays and
> returns.
>
> **Recommendation:** (1) Add size charts / fit-quiz prompts on the specific high-return apparel and
> footwear listings identified above — a targeted fix rather than a category-wide one. (2) Prioritize
> carrier reliability improvements on Standard shipping specifically, since it has both the most volume
> and the highest delay rate of the three tiers, and delay is measurably tied to returns.

---

## Methodology notes & limitations

- **Synthetic data:** generated with `01_generate_data.py` using seeded randomness with embedded
  business logic (category cost ratios, return-rate multipliers, channel-conditioned retention, etc.)
  rather than pure noise — but it is not real transactional data, and absolute figures shouldn't be
  read as benchmarks for any real business.
- **Snapshot date:** all recency/churn/CAC calculations use 2026-08-31 as "today." Recent cohorts
  (acquired in the last few months) are intentionally excluded from the retention-curve average since
  they haven't had time to make a second purchase yet.
- **CLV** here is historical (total net revenue per customer to date), not a forward-looking predictive
  model — a reasonable and transparent choice for a case study, but worth stating explicitly.
- **SQLite, not PostgreSQL/Docker:** the project ships a working SQLite database (`data/ecommerce.db`)
  built directly from `sql/01_schema.sql` so anyone can query it with zero setup. The schema and
  queries are ~95% Postgres-portable; see the dialect notes at the top of the schema file.
