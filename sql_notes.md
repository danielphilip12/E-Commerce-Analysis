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