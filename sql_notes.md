# Olist Brazilian E-Commerce — SQL Analysis Notes

## Project Setup

- **Dataset:** Olist Brazilian E-Commerce (Kaggle: `olistbr/brazilian-ecommerce`)
- **Database:** PostgreSQL 18.4, port 5433
- **Client:** DBeaver 26.1.0
- **Tools:** SQL, Excel, Python, Power BI

### Tables Loaded

| Table | Row Count |
|---|---|
| customers | 99,441 |
| geolocation | 1,000,163 |
| order_items | 112,650 |
| order_payments | 103,886 |
| order_reviews | 99,224 |
| orders | 99,441 |
| product_category_name_translation | 71 |
| products | 32,951 |
| sellers | 3,095 |

### Data Quality Notes

- All 99,441 orders have a customer, status, and purchase timestamp
- 2,965 orders are missing a delivery date — expected for non-delivered statuses
- 96,478 orders have a status of `delivered` — this is the primary analysis population

### Order Status Breakdown

| Status | Count |
|---|---|
| delivered | 96,478 |
| shipped | 1,107 |
| canceled | 625 |
| unavailable | 609 |
| invoiced | 314 |
| processing | 301 |
| created | 5 |
| approved | 2 |

---

## Task 1 — Monthly Order Volume

### Objective
Get a high level picture of order volume over time using purchase timestamp, sorted chronologically ascending.

### Query

```sql
SELECT TO_CHAR(o.order_purchase_timestamp, 'YYYY-MM') AS month, COUNT(*)
FROM orders o
GROUP BY 1
ORDER BY 1 ASC;
```

### Results

| Month | Order Count |
|---|---|
| 2016-09 | 4 |
| 2016-10 | 324 |
| 2016-12 | 1 |
| 2017-01 | 800 |
| 2017-02 | 1,780 |
| 2017-03 | 2,682 |
| 2017-04 | 2,404 |
| 2017-05 | 3,700 |
| 2017-06 | 3,245 |
| 2017-07 | 4,026 |
| 2017-08 | 4,331 |
| 2017-09 | 4,285 |
| 2017-10 | 4,631 |
| 2017-11 | 7,544 |
| 2017-12 | 5,673 |
| 2018-01 | 7,269 |
| 2018-02 | 6,728 |
| 2018-03 | 7,211 |
| 2018-04 | 6,939 |
| 2018-05 | 6,873 |
| 2018-06 | 6,167 |
| 2018-07 | 6,292 |
| 2018-08 | 6,512 |
| 2018-09 | 16 |
| 2018-10 | 4 |

### Key Findings

- **Strong growth trajectory** from late 2016 through mid 2018
- **November 2017 spike to 7,544** — nearly double October 2017, attributed to Black Friday / holiday season
- **Business maturity by early 2018** — stabilized at roughly 6,000–7,000 orders per month

### Anomalies & Interpretation

- **2016-09 (4 orders) and 2016-12 (1 order):** Olist was just getting started on the platform in late 2016. This is genuinely low volume in the early days, not missing data.
- **2018-09 (16 orders) and 2018-10 (4 orders):** Data cutoff issue. The dataset was extracted in October 2018, so these months are incomplete. Orders not yet delivered or reviewed may not have made it into the extract fully.

### Analytical Decision

> Filter all time-based analysis to **October 2016 through August 2018** to avoid drawing conclusions from incomplete periods at either end of the dataset.

## Task 2 - Delivery Performance Overview

### Objective 
Get the average number of days between the order purchase and it's estimated delivery vs the days between it's actual delivery. 

### Query
```sql
select 
	avg(o.order_delivered_customer_date - o.order_purchase_timestamp) as avg_delivery, 
	avg(o.order_estimated_delivery_date  - o.order_purchase_timestamp ) as avg_estimated_delivery
from orders o 
where o.order_status = 'delivered'
```

### Results

| avg_delivery | avg_estimated_delivery |
| --- | --- |
| 12 days 13:23:49.957272 | 23 days 17:40:20.385798 |

### Key Findings

- **Average Actual Delivery**: ~12.5 days
- **Average Estimated Delivery**: ~23.75 days
- **Underpromising and Overdelivering**: Olist seems to be employing the strategy of _Underpromising and Overdelivering_ in order to keep the customer satisfaction high. A customer who expects a delivery in 23 days will be very happy to get their order in 12 days, while a customer that expects it in 12 days, but gets it in 14 will be annoyed, but not horribly so. 

> Hypothesis to test later: Orders that arrived close to or after the estimated delivery date may correlate with lower review scores. We'll revisit this during review score analysis.

## Task 3 — Delivery Performance by State

### Objective
Find the average actual delivery days by customer state to identify regional performance gaps.

### Query
```sql
SELECT c.customer_state, 
       AVG(o.order_delivered_customer_date - o.order_purchase_timestamp) AS avg_actual_delivery
FROM orders o
JOIN customers c USING (customer_id)
WHERE o.order_status = 'delivered'
GROUP BY c.customer_state
ORDER BY 2 DESC;
```

### Results
| customer_state | avg_actual_delivery |
|---|---|
| RR | 28 days 33:18:03.97561 |
| AP | 26 days 28:26:29.850746 |
| AM | 25 days 34:13:25.613793 |
| AL | 24 days 13:03:09.103275 |
| PA | 23 days 18:33:00.021142 |
| MA | 21 days 13:45:05.167364 |
| SE | 21 days 12:28:29.707463 |
| CE | 20 days 30:23:52.394058 |
| AC | 20 days 24:51:25.6 |
| PB | 19 days 34:14:32.72147 |
| PI | 18 days 34:58:13.289916 |
| RO | 18 days 32:55:43.954732 |
| BA | 18 days 32:03:04.247236 |
| RN | 18 days 30:40:32.696203 |
| PE | 17 days 34:45:35.106717 |
| MT | 17 days 25:20:17.319413 |
| TO | 17 days 15:47:36.60949 |
| ES | 15 days 18:56:36.134336 |
| MS | 15 days 14:50:22.763195 |
| GO | 15 days 14:33:07.649464 |
| RJ | 14 days 31:25:35.403644 |
| RS | 14 days 31:12:23.863024 |
| SC | 14 days 22:54:53.240552 |
| DF | 12 days 23:13:17.884615 |
| MG | 11 days 24:12:28.711819 |
| PR | 11 days 23:47:52.704448 |
| SP | 8 days 18:16:23.750062 |

### Key Findings
- **Slowest state — RR (Roraima):** 28+ days on average, nearly a full month per delivery
- **Fastest state — SP (São Paulo):** Only ~8.5 days on average — Olist is headquartered here and the majority of sellers are São Paulo based, making most orders effectively local
- **3.4x gap** between the best and worst served states — this is not a minor logistics variance, it represents a meaningful customer experience inequality across regions
- **Clear geographic pattern:** Northern and northeastern states (RR, AP, AM, AL, PA) are the slowest due to remote locations, limited infrastructure, and long haul distances. Southern and southeastern states (SP, PR, MG) are the fastest
- **Distribution center hypothesis:** The concentration of sellers and likely fulfillment infrastructure in São Paulo is a primary driver of this disparity. States further from SP face compounding logistics challenges

### Action Item
> Investigate seller and distribution center locations relative to the slowest performing states. Expanding fulfillment presence in the north and northeast could significantly reduce delivery times and improve customer satisfaction in underserved regions.

### Hypothesis to Test Later
> If remote states have longer delivery times, do they also have lower review scores? We should expect a negative correlation between delivery days and review score — we'll revisit this during review score analysis.

## Task 4 — Revenue Overview

### Objective
Find the total revenue by month to understand Olist's revenue trend over time and compare it against order volume.

### Query
```sql
SELECT 
    TO_CHAR(o.order_purchase_timestamp, 'YYYY-MM') AS month, 
    SUM(oi.price + oi.freight_value) AS total_revenue
FROM orders o
JOIN order_items oi 
USING (order_id)
GROUP BY 1 
ORDER BY 1 ASC;
```

### Results

| month | total_revenue |
|---|---|
| 2016-09 | 354.75 |
| 2016-10 | 56,808.84 |
| 2016-12 | 19.62 |
| 2017-01 | 137,188.49 |
| 2017-02 | 286,280.62 |
| 2017-03 | 432,048.59 |
| 2017-04 | 412,422.24 |
| 2017-05 | 586,190.95 |
| 2017-06 | 502,963.04 |
| 2017-07 | 584,971.62 |
| 2017-08 | 668,204.60 |
| 2017-09 | 720,398.91 |
| 2017-10 | 769,312.37 |
| 2017-11 | 1,179,143.77 |
| 2017-12 | 863,547.23 |
| 2018-01 | 1,107,301.89 |
| 2018-02 | 986,908.96 |
| 2018-03 | 1,155,126.82 |
| 2018-04 | 1,159,698.04 |
| 2018-05 | 1,149,781.82 |
| 2018-06 | 1,022,677.11 |
| 2018-07 | 1,058,728.03 |
| 2018-08 | 1,003,308.47 |
| 2018-09 | 166.46 |

### Key Findings
- **Consistent growth trajectory:** Revenue grows steadily from late 2016 through mid 2018, mirroring the order volume trend seen in Task 1 — a healthy sign that average order value is relatively stable rather than being driven by a few large orders
- **November 2017 spike — Black Friday effect:** Revenue jumps to 1.17M BRL in November 2017, nearly 53% higher than October 2017 (769K BRL), consistent with the order volume spike seen in Task 1 and almost certainly driven by Black Friday and holiday season shopping
- **2018 stabilization:** Revenue plateaus at roughly 1M–1.16M BRL per month through 2018, consistent with the order volume plateau identified in Task 1
- **Incomplete data periods:** As established in Task 1, September and December 2016 and September 2018 reflect incomplete data collection periods and should be excluded from trend analysis

### Hypothesis to Test Later
> Does the November 2017 revenue spike look proportionally larger than the order volume spike? If revenue grew more than volume, it would suggest customers were spending more per order during the holiday season — pointing to higher average order values in peak periods. We'll revisit this when we analyze average order value.

### Analytical Decision
> Continue filtering all time-based analysis to **October 2016 through August 2018** to exclude incomplete data periods at either end of the dataset.

## Task 5 — Top 15 Product Categories by Revenue

### Objective
Find the top 15 product categories by total revenue to identify Olist's most lucrative areas and inform inventory and marketing strategy.

### Query
```sql
SELECT 
    pcnt.product_category_name_english AS category,
    SUM(oi.price + oi.freight_value) AS total_revenue
FROM products p 
JOIN product_category_name_translation pcnt 
    USING (product_category_name)
JOIN order_items oi 
    USING (product_id)
GROUP BY 1
ORDER BY 2 DESC
LIMIT 15;
```

### Results
| category | total_revenue |
|---|---|
| health_beauty | 1,441,248.07 |
| watches_gifts | 1,305,541.61 |
| bed_bath_table | 1,241,681.72 |
| sports_leisure | 1,156,656.48 |
| computers_accessories | 1,059,272.40 |
| furniture_decor | 902,511.79 |
| housewares | 778,397.77 |
| cool_stuff | 719,329.95 |
| auto | 685,384.32 |
| garden_tools | 584,219.21 |
| toys | 561,372.55 |
| baby | 480,118.00 |
| perfumery | 453,338.71 |
| telephony | 394,883.32 |
| office_furniture | 342,532.65 |

### Key Findings
- **Top category — Health & Beauty:** Leads all categories at 1.44M BRL, nearly 4x the revenue of 15th place Office Furniture (342K BRL), suggesting significantly higher demand and/or average order value in this category
- **Broad marketplace model confirmed:** The top 5 categories span health, gifts, home, sports, and electronics — no single vertical dominates, indicating Olist operates as a true general marketplace rather than being reliant on one product type
- **Lifestyle and consumer goods dominate:** The majority of the top 15 are everyday consumer categories (home, beauty, leisure, toys, baby), which points to a largely retail consumer base rather than a business or specialty buyer base
- **Steep drop-off after top 5:** The top 5 categories generate between 1.06M–1.44M BRL each. From rank 6 onward revenue drops noticeably, with `furniture_decor` at 902K BRL and declining steadily to `office_furniture` at 342K BRL

### Action Items
> - **Double down on the top 3** (health_beauty, watches_gifts, bed_bath_table) — these categories have proven demand and should be prioritized for seller recruitment, promotional campaigns, and inventory depth
> - **Investigate the gap between top 5 and the rest** — understanding whether lower-ranked categories have fewer sellers, lower prices, or less demand could reveal growth opportunities
> - **Monitor lifestyle categories seasonally** — toys, baby, and perfumery likely spike during holidays and gifting seasons, which could inform targeted promotions around those periods