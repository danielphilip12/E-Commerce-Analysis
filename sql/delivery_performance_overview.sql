select 
	avg(o.order_delivered_customer_date - o.order_purchase_timestamp) as avg_delivery, 
	avg(o.order_estimated_delivery_date  - o.order_purchase_timestamp ) as avg_estimated_delivery
from orders o 
where o.order_status = 'delivered'