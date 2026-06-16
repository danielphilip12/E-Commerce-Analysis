select 
	t.review_score,
	count(*) as review_count,
	round(count(*) * 100.0 / sum(count(*)) over(), 2) as review_percentage
from order_reviews t 
group by 1
order by 1 desc;