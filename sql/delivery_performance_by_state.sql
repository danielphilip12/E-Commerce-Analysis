-- delivery performance by state

SELECT c.customer_state, 
       AVG(o.order_delivered_customer_date - o.order_purchase_timestamp) AS avg_actual_delivery
FROM orders o
JOIN customers c USING (customer_id)
WHERE o.order_status = 'delivered'
GROUP BY c.customer_state
ORDER BY 2 DESC;