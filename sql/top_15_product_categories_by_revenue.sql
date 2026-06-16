--select * from products
--limit 10;
--
--select * from product_category_name_translation pcnt 
--limit 10;
--
--select * from
--order_items oi 
--limit 10;

select 
	pcnt.product_category_name_english as category,
	sum(oi.price + oi.freight_value) as total_revenue
from products p 
join product_category_name_translation pcnt 
using (product_category_name)
join order_items oi 
using (product_id)
group by 1
order by 2 desc
limit 15;