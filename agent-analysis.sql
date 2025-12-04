/* Table previews */ 
select * from real_estate_data.agents
limit 10;

select * from real_estate_data.calls
limit 10;

select * from real_estate_data.customers
limit 10;

select * from real_estate_data.sales
limit 10;

/* Troubleshoot Michael Lewis and Orlando, FL */ 
select 
	*, 
    hex(market_id) as hex_value, 
    length(market_id) as len
from real_estate_data.agents
where 
	first_name = 'Michael'
	and last_name = 'Lewis';
    
select 
	market_id, 
    hex(market_id) as hex_value, 
    length(market_id) as len
from real_estate_data.markets
where market_id like '%orlando%';

/* Joining customers and sales */ 
select * from real_estate_data.customers as c

join real_estate_data.sales as s
on s.customer_id = c.customer_id;

/* Total agents: 869 */ 
select 
	distinct concat(first_name, ' ', last_name) as agent
from real_estate_data.agents;

/* Avg total closes: 42 */
select 
	avg(buyer_closes_2024 + seller_closes_2024)
from real_estate_data.agents;
    
/* Building agent export */ 
with agent_sales as (
	select
		assigned_agent, 
		market_id, 
		sum(cast(replace(replace(amount, '$', ''), ',', '') as signed)) as total
	from real_estate_data.customers as c

	join real_estate_data.sales as s
	on s.customer_id = c.customer_id

	group by 
		assigned_agent, 
		market_id
)

select 
	concat(first_name, ' ', last_name, ' ', regexp_substr(agent_id, '[0-9]+$')) as agent, 
    agent_id,
    m.market_id,
    m.common_name,
    buyer_closes_2024, 
    buyer_customers_sent_2024, 
    round(buyer_closes_2024 / buyer_customers_sent_2024, 2) as 2024_buyer_conversion, 
    seller_closes_2024, 
    seller_customers_sent_2024, 
    round(seller_closes_2024 / seller_customers_sent_2024, 2) as 2024_seller_conversion, 
    buyer_closes_2024 + seller_closes_2024 as total_closes, 
    buyer_customers_sent_2024 + seller_customers_sent_2024 as total_sent,
    round((buyer_closes_2024 + seller_closes_2024) / (buyer_customers_sent_2024 + seller_customers_sent_2024), 2) as 2024_total_conversion, 
    customer_reviews_2024, 
    avg_rating_2024, 
    agent_sales.total as total_price,
    round((agent_sales.total / seller_closes_2024), 2) as avg_price,
    cast(replace(replace(m.price_closed_median, '$', ''), ',', '') as signed) as market_median, 
    round(((agent_sales.total / seller_closes_2024)
		- cast(replace(replace(m.price_closed_median, '$', ''), ',', '') as signed))
        / cast(replace(replace(m.price_closed_median, '$', ''), ',', '') as signed), 2) as difference_from_median
from real_estate_data.agents as a

left outer join real_estate_data.markets as m
on replace(a.market_id, 'fla', 'fl') = trim(m.market_id)

left join agent_sales
on agent_sales.assigned_agent = a.agent_id
and agent_sales.market_id = m.market_id

where 
	customer_reviews_2024 > 5;

/* Total sales per agent and market CTE */ 
select
	assigned_agent, 
    market_id, 
    sum(cast(replace(replace(amount, '$', ''), ',', '') as signed)) as total
from real_estate_data.customers as c

join real_estate_data.sales as s
on s.customer_id = c.customer_id

group by 
	assigned_agent, 
    market_id;

/* 
Checking CTE logic on Sofia Smith

- Market: Phoenix, AZ
- Total seller closes: 19
- CTE sales total: $9,549,466
 */ 
select * from real_estate_data.customers as c
join real_estate_data.sales as s
on s.customer_id = c.customer_id
where c.assigned_agent = 'sofia_smith_808';

select * from real_estate_data.agents
where agent_id = 'sofia_smith_808';