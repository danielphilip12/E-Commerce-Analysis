select 
	to_char(o.order_purchase_timestamp, 'YYYY-MM') as month, 
	sum(oi.price + oi.freight_value) as total_revenue
from orders o
join order_items oi 
using (order_id)
group by 1 
order by 1 asc;