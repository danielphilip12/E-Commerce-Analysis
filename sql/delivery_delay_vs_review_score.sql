select 
	t.review_score,
	avg(o.order_delivered_customer_date - o.order_estimated_delivery_date ) as avg_delay
from orders o 
join order_reviews t 
using (order_id)
where o.order_status = 'delivered'
group by 1
order by 1 desc;