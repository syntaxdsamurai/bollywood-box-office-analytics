

select * from stg_bollywood_raw limit 10;

select count (*) from stg_bollywood_raw ;



select count(*) from stg_bollywood_raw where verdict is null or verdict = ''; --142

select distinct count(*), verdict from stg_bollywood_raw sbr 
group  by verdict 
order by count desc;

--142	
--67	Disaster
--30	Flop
--26	Hit
--18	SuperHit
--13	Average
--13	Below Average
--11	Blockbuster
--9	Above Average
--9	All Time Blockbuster

select count(*) from stg_bollywood_raw where budget = '1'; --124

select count(*) from stg_bollywood_raw where worldwide is null or worldwide = ''; --17




with returnoninvestment as 
(select
movie,
nullif(budget,'')::numeric as budget,
nullif(worldwide,'')::numeric as worldwide,
nullif(india_gross,'')::numeric as india_gross,
(nullif(worldwide,'')::numeric/nullif(budget,'')::numeric) * 100 as ROI
from stg_bollywood_raw 
where budget is not null and budget != '' and nullif(budget,'') != '1')
select 
	worldwide,
	india_gross,
	budget,
	ROI,
	case 
		when ROI > 300 then 'All Time Blockbuster'
		when ROI > 200 then 'Blockbuster'
		when ROI > 150 then 'SuperHit'
		when ROI > 100 then 'Hit'
		when ROI > 75 then 'Below Average'
		when ROI > 50 then 'Flop'
		else 'Disaster'
	end as newverdict	
from returnoninvestment;


with returnoninvestment as 
(select
movie,
nullif(budget,'')::numeric as budget,
nullif(worldwide,'')::numeric as worldwide,
nullif(india_gross,'')::numeric as india_gross,
(nullif(worldwide,'')::numeric/nullif(budget,'')::numeric) * 100 as ROI
from stg_bollywood_raw 
where budget is not null and budget != '' and nullif(budget,'') != '1')
select 
count(*) from returnoninvestment;







SELECT COUNT(*) FROM dim_date;
SELECT COUNT(*) FROM dim_verdict;
SELECT COUNT(*) FROM fact_movies;


SELECT release_date 
FROM stg_bollywood_raw 
LIMIT 5;

select count(*) from stg_bollywood_raw;

SELECT * FROM stg_bollywood_raw LIMIT 20;


SELECT
    f.movie,
    d.year,
    d.festive_season,
    v.verdict_label,
    f.budget,
    f.worldwide,
    ROUND(f.roi, 2) AS roi
FROM fact_movies f
JOIN dim_date d ON f.date_id = d.date_id
JOIN dim_verdict v ON f.verdict_id = v.verdict_id
ORDER BY f.roi DESC
LIMIT 10;

SELECT
    d.festive_season,
    COUNT(*) AS movies,
    ROUND(AVG(f.roi), 2) AS avg_roi,
    ROUND(AVG(f.worldwide), 2) AS avg_collection
FROM fact_movies f
JOIN dim_date d ON f.date_id = d.date_id
GROUP BY d.festive_season
ORDER BY avg_roi DESC;


SELECT
    d.year,
    COUNT(*) AS movies,
    ROUND(AVG(f.roi), 2) AS avg_roi
FROM fact_movies f
JOIN dim_date d ON f.date_id = d.date_id
GROUP BY d.year
ORDER BY avg_roi DESC;


SELECT
    v.verdict_label,
    COUNT(*) AS movies
FROM fact_movies f
JOIN dim_verdict v ON f.verdict_id = v.verdict_id
GROUP BY v.verdict_label, v.verdict_tier
ORDER BY v.verdict_tier;

