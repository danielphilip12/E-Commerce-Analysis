with customer_purchase_counts as
(
select
	c.customer_unique_id ,
	count(o.order_id) as "# of orders"
from
	orders o
join customers c
		using (customer_id)
group by
	c.customer_unique_id
)
select 
	count(distinct customer_unique_id) as unique_customers, 
	count(case when "# of orders" > 1 then 1 end) as repeat_customers,
	round(
		count(case when "# of orders" > 1 then 1 end) * 100.0 / count(distinct customer_unique_id),
		2
	) as repeat_purchase_percentage
from customer_purchase_counts ;