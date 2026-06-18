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