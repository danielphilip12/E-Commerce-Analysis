select to_char(o.order_purchase_timestamp, 'YYYY-MM') as month, count(*)
from orders o 
group by 1
order by 1 asc;