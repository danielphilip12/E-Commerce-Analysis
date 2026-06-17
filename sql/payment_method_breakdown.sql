select 
	payment_type, 
	count(order_id) as "# of orders", 
	sum(payment_value) as "total revenue", 
	round(avg(payment_installments), 1) as "average installments"
from
	order_payments op
group by
	1
order by
	3 desc;