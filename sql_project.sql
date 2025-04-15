CREATE TABLE netflix
(
    show_id      VARCHAR(5),
    type         VARCHAR(10),
    title        VARCHAR(250),
    director     VARCHAR(550),
    casts        VARCHAR(1050),
    country      VARCHAR(550),
    date_added   VARCHAR(55),
    release_year INT,
    rating       VARCHAR(15),
    duration     VARCHAR(15),
    listed_in    VARCHAR(250),
    description  VARCHAR(550)
);
select * from netflix;

-- 1. Count the Number of Movies vs TV Shows
SELECT 
    type,
    COUNT(*)
FROM netflix
GROUP BY 1;

-- 2. Find the Most Common Rating for Movies and TV Shows 

  select type,rating,
  ranking
  from(
   select
   type, 
  rating, 
  count(*) as total_count,
  rank() over (partition by type order by count(*) desc)as ranking
  from netflix
  group by 1,2
  ) as t1
  where ranking =1;

-- 3. List All Movies Released in a Specific Year (e.g., 2020)
select title from netflix where type='movie'and release_year=2020

-- 4. Find the Top 5 Countries with the Most Content on Netflix
      
   select unnest (string_to_array(country ,','))as new_country,
   
      count(show_id) as total_count 
from netflix
   group by 1
   order by total_count desc
   limit 5


  -- 5. Identify the Longest Movie

  select * from netflix
  where 
  type='Movie'
  order by split_part(duration,' ',1)::int desc
  
  -- 6. Find Content Added in the Last 5 Years
  select 
      *
      
  from netflix 
  where 
        TO_DATE(date_added, 'month dd,yyyy') >= current_date - interval '5 years'

  -- 7. Find All Movies/TV Shows by Director 'Rajiv Chilaka'
  SELECT *
FROM (
    SELECT 
        *,
        UNNEST(STRING_TO_ARRAY(director, ',')) AS director_name
    FROM netflix
) AS t
WHERE director_name = 'Rajiv Chilaka';

-- 8.List All TV Shows with More Than 5 Seasons

select * from netflix 
where type='TV Show'
and
  split_part(duration,' ',1):: int>5

-- 9. Count the Number of Content Items in Each Genre
   select 
   unnest (string_to_array(listed_in,','))as new_list,
  count(show_id) as total_content
 from netflix
 group by 1 

-- 10.Find each year and the average numbers of content release in India on netflix.
 select EXTRACT(YEAR from TO_DATE(date_added, 'month dd,yyyy'))as year,
  count(show_id) as total_content, 
  round(count(show_id)::numeric / (
  select count(*) from netflix where country='India'
  )::numeric*100,2) as avg_content
  
 from netflix
 where country='India'
 group by 1
 
 -- 11. List All Movies that are Documentaries

 SELECT * 
FROM netflix
WHERE listed_in LIKE '%Documentaries';

-- 13. Find How Many Movies Actor 'Salman Khan' Appeared in the Last 10 Years
 SELECT * 
FROM netflix
WHERE casts LIKE '%Salman Khan%'
  AND release_year > EXTRACT(YEAR FROM CURRENT_DATE) - 10;

  --14. Find the Top 10 Actors Who Have Appeared in the Highest
  --number of Movies Produced in India
  select 
   UNNEST(STRING_TO_ARRAY(casts, ',')) AS cast_name,
    count(*)as total_content
	
 
  from netflix
  where country like '%India' 
  group by 1
  order by 2 desc
  limit 10

-- 15. Categorize Content Based on the Presence of 
--'Kill' and 'Violence' Keywords Categorize content as 'Bad' if it contains
--'kill' or 'violence' and 'Good' otherwise. 
with new_table as(


select *,
    case 
	when description Ilike '%kill%' or 
	     description ilike '%violence%' then 'BAD'     -- ilike for case insensitive
		 else 'GOOD'
    end category
		  
from netflix
)
select category,
count(*) as total_content
from new_table
group by 1

