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

## Task 6 — Review Score Distribution

### Objective
Find the count and percentage of orders for each review score (1–5) to assess overall customer satisfaction across the platform.

### Query
```sql
SELECT 
    t.review_score,
    COUNT(*) AS review_count,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2) AS review_percentage
FROM order_reviews t 
GROUP BY 1
ORDER BY 1 DESC;
```

### Results
| review_score | review_count | review_percentage |
|---|---|---|
| 5 | 57,328 | 57.78% |
| 4 | 19,142 | 19.29% |
| 3 | 8,179 | 8.24% |
| 2 | 3,151 | 3.18% |
| 1 | 11,424 | 11.51% |

### Key Findings
- **Majority positive:** 5-star ratings account for 57.78% of all reviews, and combined with 4-star ratings, **77% of all orders receive a positive rating** — a strong overall satisfaction signal
- **1-star ratings are the third most common score:** At 11.51%, 1-star reviews are more frequent than 2-star (3.18%) and 3-star (8.24%) combined — this is a classic bimodal distribution where customers tend to either love or hate their experience, with little middle ground
- **The 1-star problem is not negligible:** Over 11,000 orders received the worst possible rating. At Olist's scale this represents a meaningful volume of unhappy customers and potential churn
- **Scores 2 and 3 are relatively rare:** Only 11.42% of reviews fall in the middle range, suggesting customers rarely feel neutral — they either had a good experience or a bad one

### Action Items
> - **Investigate 1-star drivers:** Cross-reference 1-star reviews with delivery delay data to test whether late deliveries are the primary cause — this ties directly into our delivery performance findings from Tasks 2 and 3
> - **Prioritize the bimodal pattern in Power BI:** The contrast between 5-star and 1-star volumes will make for a compelling visual in the dashboard
> - **Segment by state:** Given the large delivery time gaps identified in Task 3, states with the longest delivery times (RR, AP, AM) may also show higher rates of 1-star reviews — worth testing in a future query

### Hypothesis to Test Next
> Do orders with longer delivery times — particularly those that arrived late relative to the estimated date — correlate with lower review scores? We flagged this in Tasks 2 and 3 and now have the review data to test it.

## Task 7 — Delivery Delay vs Review Score

### Objective
Test the hypothesis that late deliveries drive lower review scores by comparing average delivery delay against review score. A negative delay means the order arrived early; a positive delay means it arrived late.

### Query
```sql
SELECT 
    t.review_score,
    AVG(o.order_delivered_customer_date - o.order_estimated_delivery_date) AS avg_delay
FROM orders o 
JOIN order_reviews t 
    USING (order_id)
WHERE o.order_status = 'delivered'
GROUP BY 1
ORDER BY 1 DESC;
```

### Results
| review_score | avg_delay |
|---|---|
| 5 | -12 days 16:30:26 |
| 4 | -11 days 16:25:04 |
| 3 | -9 days 25:57:11 |
| 2 | -7 days 22:30:45 |
| 1 | -3 days 08:35:38 |

### Key Findings
- **Hypothesis partially supported — but with a twist:** Every review score group received their order early on average, meaning late delivery is not the sole driver of 1-star reviews. However, the pattern is still very clear and meaningful
- **Strong correlation between earliness and satisfaction:** 5-star orders arrived ~12.7 days early on average, while 1-star orders arrived only ~3.4 days early — a 9+ day difference. The earlier the delivery, the higher the review score
- **1-star orders still arrived early:** Even dissatisfied customers received their orders ~3.4 days ahead of the estimate on average, which strongly suggests that **factors beyond delivery timing** — such as product quality, damaged goods, wrong items, or seller communication — are primary drivers of poor reviews
- **The underpromise/overdeliver strategy from Task 2 is confirmed here:** Customers who experienced the largest gap between expectation and reality (earliest deliveries) gave the best ratings, validating Olist's conservative estimation approach

### Action Items
> - **Investigate 1-star review comments:** The text in `review_comment_message` may reveal what customers are actually complaining about — product quality, wrong items, damaged packaging, or poor seller communication are likely culprits
> - **Don't over-index on delivery speed as the fix:** This data suggests that improving delivery times alone will not resolve the 1-star problem — product and seller quality need to be examined
> - **Flag for Power BI:** A visual showing the clear staircase pattern between delivery earliness and review score will be a compelling dashboard element

### Hypothesis Outcome
> **Partially confirmed.** Delivery timing does correlate with review scores — earlier deliveries earn higher ratings — but late delivery alone does not explain 1-star reviews, since even 1-star orders arrived early on average. The root cause of poor reviews likely lies elsewhere, such as product quality or seller behavior.

## Task 8 — Payment Method Breakdown

### Objective
Find the breakdown of payment methods by order count, total revenue, and average installments to understand how customers prefer to pay on the Olist platform.

### Query
```sql
SELECT 
    payment_type, 
    COUNT(order_id) AS order_count, 
    SUM(payment_value) AS total_revenue, 
    ROUND(AVG(payment_installments), 1) AS avg_installments
FROM order_payments op
GROUP BY 1
ORDER BY 3 DESC;
```

### Results
| payment_type | order_count | total_revenue | avg_installments |
|---|---|---|---|
| credit_card | 76,795 | 12,542,084.19 | 3.5 |
| boleto | 19,784 | 2,869,361.27 | 1.0 |
| voucher | 5,775 | 379,436.87 | 1.0 |
| debit_card | 1,529 | 217,989.79 | 1.0 |
| not_defined | 3 | 0.00 | 1.0 |

### Key Findings
- **Credit card dominates overwhelmingly:** 76,795 orders paid by credit card, generating 12.54M BRL — that's **77% of all orders and roughly 79% of total revenue**, making it by far the most important payment method on the platform
- **Installments are a credit card phenomenon:** The average of 3.5 installments for credit card vs 1.0 for every other method confirms that installment payments are uniquely tied to credit card usage — a well known cultural norm in Brazil where consumers routinely split purchases into monthly payments
- **Boleto is a distant but meaningful second:** With 19,784 orders and 2.87M BRL in revenue, boleto (a Brazilian bank slip payment method) is the only other significant payment channel, reflecting its widespread use among Brazilians without credit cards or who prefer not to use them online
- **Debit card and voucher are minor channels:** Together they account for less than 4% of orders and revenue, suggesting limited adoption or availability
- **3 orders with `not_defined` and zero revenue:** Likely test orders or data entry errors — negligible but worth noting as a data quality flag

### Action Items
> - **Protect the credit card experience:** Since 79% of revenue flows through credit card, any friction in the checkout or payment processing for credit cards would have an outsized impact on the business
> - **Investigate installment behavior further:** Do higher installment counts correlate with higher order values or specific product categories? Customers buying big ticket items (computers, furniture) may be splitting into more installments — worth exploring
> - **Monitor boleto conversion:** Boleto orders can be abandoned if the customer never pays the slip. It would be worth investigating whether boleto orders have a higher cancellation rate than credit card orders

### Cultural Context
> Installment payments ("parcelamento") are deeply embedded in Brazilian consumer culture. It is common for Brazilians to split even small purchases into multiple monthly payments, which explains why the average credit card order uses 3.5 installments. This is a uniquely Brazilian dynamic that would not appear in equivalent datasets from the US or Europe, and makes this dataset particularly interesting for demonstrating cultural data literacy.

## Task 9 — Customer Retention & Repeat Purchase Rate

### Objective
Determine how many customers placed more than one order to assess Olist's customer retention and loyalty, using a CTE to first calculate order counts per unique customer before summarizing at the platform level.

### Query
```sql
WITH customer_purchase_counts AS (
    SELECT
        c.customer_unique_id,
        COUNT(o.order_id) AS "# of orders"
    FROM orders o
    JOIN customers c
        USING (customer_id)
    GROUP BY c.customer_unique_id
)
SELECT
    COUNT(DISTINCT customer_unique_id) AS unique_customers,
    COUNT(CASE WHEN "# of orders" > 1 THEN 1 END) AS repeat_customers,
    ROUND(
        COUNT(CASE WHEN "# of orders" > 1 THEN 1 END) * 100.0 / COUNT(DISTINCT customer_unique_id),
        2
    ) AS repeat_purchase_rate
FROM customer_purchase_counts;
```

### Results
| unique_customers | repeat_customers | repeat_purchase_rate |
|---|---|---|
| 96,096 | 2,997 | 3.12% |

### Key Findings
- **Critically low retention rate:** Only 3.12% of customers placed more than one order — meaning **96.88% of Olist's customer base shops once and never returns**
- **Well below industry benchmarks:** Healthy e-commerce platforms typically see repeat purchase rates of 20–30%. At 3.12%, Olist is significantly underperforming on customer loyalty
- **Marketplace invisibility problem:** Many customers may not realize they are shopping on Olist at all — they find an individual seller through Google or social media and complete the purchase without building any brand association with Olist itself, making retention inherently more difficult in a marketplace model
- **Revenue implications are significant:** Acquiring a new customer costs significantly more than retaining an existing one. Moving the repeat purchase rate from 3.12% to even 10% would represent a substantial revenue uplift without increasing new customer acquisition spend

### Action Items
> - **Launch a customer loyalty program:** Member discounts, points systems, or exclusive offers for returning customers are proven retention levers that could meaningfully move the repeat purchase rate
> - **Email remarketing campaigns:** Re-engaging past customers with personalized recommendations based on their purchase history is a low cost, high impact retention strategy
> - **Improve Olist brand visibility:** Ensuring customers know they are shopping on Olist — not just an anonymous seller — is a prerequisite for building platform-level loyalty
> - **Segment repeat customers:** Understanding who the 2,997 repeat customers are, what they bought, and which states they're from could reveal the profile of Olist's most loyal customers and inform targeted retention campaigns

### SQL Techniques Used
- **CTE (Common Table Expression):** Used to pre-aggregate order counts per unique customer before summarizing in the outer query
- **Conditional aggregation:** `COUNT(CASE WHEN ... THEN 1 END)` used to count repeat customers inline without a subquery
- **`customer_unique_id` vs `customer_id`:** The `customers` table uses `customer_id` as a per-order identifier — `customer_unique_id` is required to correctly identify the same physical customer across multiple orders


## Task 10 — Seller Performance Tiering

### Objective
Segment all sellers into 4 performance tiers based on total revenue using `NTILE(4)`, while also surfacing order count and average review score for each seller, to help the marketplace team decide who to feature, support, or potentially offboard.

### Query
```sql
WITH cte AS (
    SELECT
        s.seller_id,
        SUM(oi.price + oi.freight_value) AS total_revenue,
        COUNT(order_id) AS order_count,
        ROUND(AVG(t.review_score), 2) AS avg_review
    FROM sellers s
    JOIN order_items oi
        USING (seller_id)
    LEFT JOIN order_reviews t
        USING (order_id)
    GROUP BY s.seller_id
)
SELECT
    seller_id,
    total_revenue,
    order_count,
    avg_review,
    NTILE(4) OVER (ORDER BY total_revenue DESC) AS tier
FROM cte
ORDER BY total_revenue DESC;
```

### Results (sample — tier 1 top performers)
| seller_id | total_revenue | order_count | avg_review | tier |
|---|---|---|---|---|
| 4869f7a5dfa277a7dca6462dcf3b52b2 | 249,640.70 | 1,156 | 4.12 | 1 |
| 7c67e1448b00f6e969d365cea6b010ab | 241,374.82 | 1,375 | 3.35 | 1 |
| 4a3ca9315b744ce9f8e9374361493884 | 238,440.31 | 2,009 | 3.80 | 1 |
| 53243585a1d6dc2643021fd1853d8905 | 235,856.68 | 410 | 4.08 | 1 |
| fa1c13f2614d7b5c4749cbc52fecda94 | 204,084.73 | 586 | 4.34 | 1 |

### Results (sample — tier 1/tier 2 boundary)
| seller_id | total_revenue | order_count | avg_review | tier |
|---|---|---|---|---|
| 7f2617c58d5d06806987308b45654351 | 3,983.27 | 23 | 3.87 | **1** |
| dd533b429f380718b70ad9922c294bae | 3,970.98 | 45 | 3.73 | **2** |
| b1ac6ea7895bc3dd6f0f6f4abbdd2821 | 3,964.33 | 41 | 4.27 | 2 |
| 432c37c9dfba871172ec162e20118b8c | 3,938.54 | 57 | 4.18 | 2 |

### Key Findings
- **Tier boundary confirmed working correctly:** The cutoff between tier 1 and tier 2 falls precisely at the revenue break ($3,983.27 → $3,970.98), confirming the `NTILE(4)` window function is correctly ranking and splitting all 3,095 sellers into 4 equal-sized groups of roughly 774 sellers each
- **Tier 1 spans an enormous revenue range:** From $249,640 down to $3,983 — nearly a 63x difference within the same tier. This is an important limitation of `NTILE`: it splits sellers into equal-*sized* groups, not equal-*revenue* bands, so "tier 1" includes both superstar sellers and fairly modest performers
- **High revenue does not guarantee high satisfaction:** Within tier 1 alone, average review scores range from as low as **1.40** up to **4.81**. Several high-revenue sellers have alarmingly poor review scores:
  - `b1b3948701c5c72445495bd161b83a4c` — $25,185 in revenue, only **1.72** average review
  - `b37c4c02bda3161a7546a4e6d222d5b2` — $24,487 in revenue, only **1.40** average review
- **Order count and revenue don't perfectly correlate:** Some sellers generate high revenue from relatively few high-priced orders, while others accumulate high order counts at lower revenue per order — these likely represent two distinct seller business models (premium/low-volume vs. budget/high-volume) worth segmenting separately in future analysis

### Action Items
> - **Flag low-review, high-revenue sellers for investigation:** Sellers like `b1b3948701c5c72445495bd161b83a4c` and `b37c4c02bda3161a7546a4e6d222d5b2` are generating significant revenue but delivering a poor customer experience — this is a direct risk to platform reputation and should be prioritized for seller support outreach or review
> - **Consider a secondary tiering dimension:** A combined score factoring in both revenue and review quality (not revenue alone) would better identify sellers worth featuring or promoting
> - **Investigate the two seller archetypes:** High-order/lower-revenue-per-order sellers vs. low-order/high-revenue-per-order sellers may need different support strategies, pricing guidance, or marketing treatment

### SQL Techniques Used
- **CTE (Common Table Expression):** Used to pre-aggregate revenue, order count, and average review score per seller before ranking in the outer query
- **Window function — `NTILE(4) OVER (ORDER BY ...)`:** Used to split all sellers into 4 equal-sized performance tiers ranked by revenue, with `ORDER BY total_revenue DESC` ensuring tier 1 represents top performers
- **Multi-table join with `LEFT JOIN`:** Reviews joined with `LEFT JOIN` since not every order has a review, preserving all seller order activity even when review data is missing