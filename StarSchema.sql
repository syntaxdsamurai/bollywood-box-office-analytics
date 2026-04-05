CREATE TABLE stg_bollywood_raw (
	row_id				integer,
	release_date		Varchar(20),
	movie				varchar(200),
	worldwide			varchar(50),
	india_hindi_net		varchar(50),
	india_gross			varchar(50),
	overseas			varchar(50),
	budget				varchar(50),
	verdict				varchar(50)
);

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



create table dim_date(
	date_id serial 	primary key,
	full_date		date,
	day				integer,
	month			integer,
	month_name		varchar(20),
	quater			integer,
	year			integer,
	festive_season	varchar(50)
);

create table dim_verdict(
	verdict_id serial primary key,
	verdict_label 	varchar(50),
	verdict_tier	integer
);


create table fact_movies(
	movie_id			serial primary key,
	movie				varchar(50),
	date_id				integer references dim_date(date_id),
	verdict_id			integer references dim_verdict(verdict_id),
	budget				Numeric,
	worldwide			Numeric,
	india_gross			Numeric,
	india_hindi_net		Numeric,
	overseas			Numeric,
	roi					Numeric
);


insert into dim_date(full_date,day,month,month_name,quater,year,festive_season)
select distinct
	release_date::date as full_date,
	extract(day from release_date::Date)::integer as day,
	extract(month from release_date:: date)::integer as month,
	to_char(release_date::date,'Month') as month_name,
	extract(quarter from release_date::date)::integer as quater,
	extract(year from release_date::date)::integer as year,
	CASE
        WHEN EXTRACT(MONTH FROM release_date::DATE) = 10
             AND EXTRACT(DAY FROM release_date::DATE) BETWEEN 1 AND 31
             THEN 'Diwali'
        WHEN EXTRACT(MONTH FROM release_date::DATE) = 11
             AND EXTRACT(DAY FROM release_date::DATE) BETWEEN 1 AND 15
             THEN 'Diwali'
        WHEN EXTRACT(MONTH FROM release_date::DATE) IN (4,5)
             THEN 'Eid'
        WHEN EXTRACT(MONTH FROM release_date::DATE) = 12
             THEN 'Christmas/NewYear'
        WHEN EXTRACT(MONTH FROM release_date::DATE) IN (1,2)
             THEN 'Republic Day/Valentine'
        ELSE 'Non Festive'
    END AS festive_season
    from stg_bollywood_raw 
    where release_date is not null
    and release_date != '';
	


INSERT INTO dim_verdict (verdict_label, verdict_tier) VALUES
('All Time Blockbuster', 1),
('Blockbuster',          2),
('SuperHit',             3),
('Hit',                  4),
('Average',              5),
('Below Average',        6),
('Flop',                 7),
('Disaster',             8);

INSERT INTO fact_movies (
    movie, date_id, verdict_id,
    budget, worldwide, india_gross,
    india_hindi_net, overseas, roi
)
WITH clean AS (
    SELECT
        s.movie,
        s.release_date::DATE AS full_date,
        nullif(s.budget,'')::NUMERIC AS budget,
        nullif(s.worldwide,'')::NUMERIC AS worldwide,
        nullif(s.india_gross,'')::NUMERIC AS india_gross,
        nullif(s.india_hindi_net,'')::NUMERIC AS india_hindi_net,
        nullif(s.overseas,'')::NUMERIC AS overseas,
        (nullif(s.worldwide,'')::NUMERIC /
         nullif(s.budget,'')::NUMERIC) * 100 AS roi,
        CASE
            WHEN (nullif(s.worldwide,'')::NUMERIC /
                  nullif(s.budget,'')::NUMERIC) * 100 > 300
                 THEN 'All Time Blockbuster'
            WHEN (nullif(s.worldwide,'')::NUMERIC /
                  nullif(s.budget,'')::NUMERIC) * 100 > 200
                 THEN 'Blockbuster'
            WHEN (nullif(s.worldwide,'')::NUMERIC /
                  nullif(s.budget,'')::NUMERIC) * 100 > 150
                 THEN 'SuperHit'
            WHEN (nullif(s.worldwide,'')::NUMERIC /
                  nullif(s.budget,'')::NUMERIC) * 100 > 100
                 THEN 'Hit'
            WHEN (nullif(s.worldwide,'')::NUMERIC /
                  nullif(s.budget,'')::NUMERIC) * 100 > 75
                 THEN 'Average'
            WHEN (nullif(s.worldwide,'')::NUMERIC /
                  nullif(s.budget,'')::NUMERIC) * 100 > 50
                 THEN 'Flop'
            ELSE 'Disaster'
        END AS calculated_verdict
    FROM stg_bollywood_raw s
    WHERE nullif(s.budget,'') IS NOT NULL
    AND nullif(s.budget,'')::NUMERIC != 1
    AND nullif(s.worldwide,'') IS NOT NULL
)
SELECT
    c.movie,
    d.date_id,
    v.verdict_id,
    c.budget,
    c.worldwide,
    c.india_gross,
    c.india_hindi_net,
    c.overseas,
    c.roi
FROM clean c
LEFT JOIN dim_date d ON d.full_date = c.full_date
LEFT JOIN dim_verdict v ON v.verdict_label = c.calculated_verdict;

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

