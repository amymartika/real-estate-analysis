/* Table preview */ 
select * from real_estate_data.markets
limit 10;

/* Markets index ranking */ 
select
	common_name, 
    increase_percentile,
    days_on_market_percentile,
    price_difference_percentile,
    round((increase_percentile + days_on_market_percentile + price_difference_percentile) / 3, 2) as ranking 
from (
	select
		common_name, 
		round(percent_rank() over (
			order by increase_percent
		), 2) as increase_percentile,
		days_on_market_percentile, 
		round(percent_rank() over (
			order by price_difference asc
		), 2) as price_difference_percentile
	from (
		select
			common_name, 
			round(listings_price_increase_count / listings_on_market_count, 2) as increase_percent, 
			days_on_market_median, 
			round(1 - (percent_rank() over (
				order by days_on_market_median asc
			)), 2) as days_on_market_percentile, 
			round((cast(replace(replace(price_closed_median, '$', ''), ',', '') as signed) 
				- cast(replace(replace(price_new_list_median, '$', ''), ',', '') as signed)) 
				/ cast(replace(replace(price_new_list_median, '$', ''), ',', '') as signed), 2) as price_difference
		from real_estate_data.markets

		group by 
			common_name, 
            increase_percent, 
            days_on_market_median, 
            price_difference
	) as t1
) as t2

order by ranking desc;

/* Detailed market view */ 
select
	common_name, 
    population,
    listings_price_increase_count,
    listings_on_market_count,
    increase_percent,
    increase_percentile,
    days_on_market_median,
    days_on_market_percentile,
    price_closed_median,
    price_new_list_median,
    price_difference,
    price_difference_percentile,
    round((increase_percentile + days_on_market_percentile + price_difference_percentile) / 3, 2) as ranking 
from (
	select
		common_name, 
		population,
		listings_price_increase_count,
		listings_on_market_count,
		increase_percent, 
		round(percent_rank() over (
			order by increase_percent
		), 2) as increase_percentile,
		days_on_market_median, 
		days_on_market_percentile, 
		price_new_list_median, 
		price_closed_median, 
		price_difference, 
		round(percent_rank() over (
			order by price_difference asc
		), 2) as price_difference_percentile
	from (
		select
			common_name, 
			population,
			listings_price_increase_count, 
			listings_on_market_count,
			round(listings_price_increase_count / listings_on_market_count, 2) as increase_percent, 
			days_on_market_median, 
			round(1 - (percent_rank() over (
				order by days_on_market_median asc
			)), 2) as days_on_market_percentile, 
			price_new_list_median, 
			price_closed_median,
			round((cast(replace(replace(price_closed_median, '$', ''), ',', '') as signed) 
				- cast(replace(replace(price_new_list_median, '$', ''), ',', '') as signed)) 
				/ cast(replace(replace(price_new_list_median, '$', ''), ',', '') as signed), 2) as price_difference
		from real_estate_data.markets

		group by 
			common_name, 
            population, 
            listings_price_increase_count, 
            listings_on_market_count, 
            increase_percent, 
            days_on_market_median, 
            price_new_list_median, 
            price_closed_median, 
            price_difference
	) as t1
) as t2

order by ranking desc;

/* Avg listings on market */ 
select
    round(avg(listings_on_market_count))
from real_estate_data.markets;