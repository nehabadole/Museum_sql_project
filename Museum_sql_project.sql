Create Database Museum_Painting;

use Museum_Paintings;


Select * from artist;
Select * from canvas_size;
Select * from image_link;
select * from museum;
Select * from museum_hours;
Select * from product_size;
Select * from subject;
Select * from work;

-- Fetch all the paintings which are not displayed on any museums?
Select work_id, name
from work 
where museum_id is null;

-- Are there museums without any paintings?
Select m.museum_id, w.work_id, w.name
from museum m
Inner Join work w
On
m.museum_id = w.museum_id
where work_id is null;

-- How many paintings have an asking price of more than their regular price?
Select count(work_id), size_id
from product_size
where sale_price > regular_price
group by size_id;

Select count(work_id)
from product_size
where sale_price > regular_price;

-- Identify the paintings whose asking price is less than 50% of its regular price
Select work_id, size_id from product_size
where sale_price < 0.5 * regular_price;

-- Which canva size costs the most?
Select size_id, sum(sale_price) as total_sale_price
from product_size
group by size_id
order by total_sale_price desc
limit 1;


-- Fetch the top 10 most famous painting subject
select subject, count(subject) as Total
from subject
group by subject
order by Total desc;

-- Identify the museums which are open on both Sunday and Monday. Display museum name, city.
Select museum_id, day from museum_hours
where day = 'Sunday';

Select museum_id, day from museum_hours
where day = 'Monday';

-- Subquery
Select m.name, m.city from museum_hours mh
Inner join museum m on mh.museum_id=m.museum_id
where mh.day = 'Sunday' and mh.museum_id In (Select museum_id from museum_hours
where day = 'Monday');

-- CTE
with sunday_open as
(Select museum_id from museum_hours
where day = 'Sunday'),
monday_open as
(Select museum_id from museum_hours
where day = 'Monday'),
common_days as
(Select s.museum_id
from sunday_open s inner join monday_open m
on s.museum_id = m.museum_id)
Select ms.name, ms.city
from common_days c inner join museum ms
on c.museum_id = ms.museum_id;

-- Delete duplicate records from work, product_size, subject and image_link tables
select work_id, count(*) from work
group by work_id
having count(*) > 1;  -- to check duplicate records

Select Count(*) from product_size;

-- Step 1:
CREATE TEMPORARY TABLE temp_product_table AS
SELECT DISTINCT * 
FROM product_size;

-- Step 2:
DELETE FROM product_size;

-- Step 3:
INSERT INTO product_size
SELECT * 
FROM temp_product_table;

-- Step 4:
DROP TEMPORARY TABLE IF EXISTS temp_product_table;

-- Delete duplicate records from work table
Select count(*) from work;

Create temporary table temp_work_table AS
Select distinct * 
from work;

Delete from work;

Insert into work 
Select * from
temp_work_table;

DROP TEMPORARY TABLE IF EXISTS temp_work_table;

-- Delete duplicate records from subject table
Select count(*) from subject;

Create temporary table temp_subject_table AS
select distinct * 
from subject;

Delete from subject;

Insert into subject
select * from
temp_subject_table;

DROP TEMPORARY TABLE IF EXISTS temp_subject_table;

-- Delete duplicate records from image_link table
Select count(*) from image_link;

Create temporary table temp_image_link_table AS
Select distinct * 
from image_link;

Delete from image_link;

Insert into image_link 
Select * from
temp_image_link_table;

DROP TEMPORARY TABLE IF EXISTS temp_image_link_table;

-- Identify the museums with invalid city information in the given dataset
Select * from museum 
where city regexp '^[0-9]';

Update museum
set city = NULL
where city regexp '^[0-9]';

Select * from museum;

-- Museum_Hours table has 1 invalid entry. Identify it and remove it.
Update museum_hours 
set day = 'Thursday'
where day = 'Thusday';

-- How many museums are open every single day?
Select count(museum_id) as museum_id_count from 
(Select museum_id, count(day) as museum_open_days
from museum_hours
group by museum_id
having museum_open_days = 7) as open_days;

-- Which are the top 5 most popular museum? (Popularity is defined based on most no of paintings in a museum)
Select m.name, count(m.museum_id) as top5_museum
from museum m inner join
work w
on m.museum_id = w.museum_id
group by m.name
order by top5_museum desc
limit 5;

Select m.name, count(*) as pop_museum
from work w
inner join museum m
on w.museum_id = m.museum_id
where m.name is not null
group by m.name
order by pop_museum
limit 5;

-- Who are the top 5 most popular artist? (Popularity is defined based on most no of paintings done by an artist)
Select a.full_name, count(w.work_id) pop_artist
from artist a
inner join work w on
a.artist_id = w.artist_id 
group by a.full_name, w.style
order by pop_artist desc
limit 5;

Select full_name from artist 
where artist_id IN(
Select artist_id from
(Select artist_id, count(artist_id) as painting_count
from work
group by artist_id
order by painting_count desc
limit 5) 
as top_artist);


with painting_count as(
select artist_id, count(work_id) as num_painting
from work
group by artist_id
)
Select a.full_name, pc.num_painting
from artist a
inner join painting_count pc
on a.artist_id = pc.artist_id
order by pc.num_painting desc
limit 5;


-- Display the 3 least popular canva sizes
with least3_pop as(
Select count(work_id) as least_pop, size_id
from product_size
group by size_id
order by least_pop)
Select c.label, lp.least_pop
from canvas_size c
inner join least3_pop lp
on c.size_id = lp.size_id
order by lp.least_pop
limit 3;

Select c.label, count(p.work_id) as least_pop
from canvas_size c
inner join product_size p
on c.size_id = p.size_id 
group by c.label
order by least_pop
limit 3;


-- Which museum is open for the longest during a day. Dispay museum name, state and hours open and which day?
with correct_data as(
    Select museum_id, day, STR_TO_DATE(open, '%h:%i:%p') AS open,
    STR_TO_DATE(close, '%h:%i:%p') AS close
    from museum_hours),
    duration_cal as (
    Select *, Timestampdiff(Minute, open, close)/60 as duration from
    correct_data
    order by duration desc
    limit 1)
    Select m.name, m.state, d.duration, d.day
    from museum m inner join duration_cal d
    on m.museum_id = d.museum_id;
    
    with date_convert as(
    Select museum_id, day, str_to_date(open, '%h:%i:%p') as open,
    str_to_date(close, '%h:%i:%p') as close
    from museum_hours),
    time_diff as(
    Select *, timestampdiff(Minute, open, close)/60 as hours_open 
    from date_convert
    order by hours_open desc
    limit 1)
    Select m.name, m.state, td.hours_open, td.day
    from museum m inner join time_diff td
    on m.museum_id = td.museum_id;
    
    -- Which museum has the most no of most popular painting style?
   With pop_painting AS(
    Select style, count(work_id) as pop_style, museum_id
    from work
    group by museum_id, style
    order by pop_style desc)
    Select m.name, p.pop_style
    from museum m inner join pop_painting p
    on m.museum_id = p.museum_id
    order by p.pop_style desc
    limit 1;
   
    
with popular_style as(
Select style, count(*) as pop_style
from work
where style is not null
group by style
order by pop_style desc
limit 1)
Select m.name , count(*) as no_of_popular_style
from work w inner join museum m on w.museum_id = m.museum_id
where w.style = (Select style from popular_style) and w.museum_id is not null
group by m.name
order by no_of_popular_style desc
limit 1;
    
    
-- Identify the artists whose paintings are displayed in multiple countries
    Select a.full_name, count(distinct m.country) as country
    from artist a inner join work w
    on a.artist_id = w.artist_id
    inner join museum m
    on m.museum_id = w.museum_id
    where m.museum_id is not null
    group by a.full_name
    having country > 1;
    
-- Display the country and the city with most no of museums. Output 2 seperate
-- columns to mention the city and country. If there are multiple value, seperate them with comma.

with total_country as(
Select Country, count(*) as no_of_museums
from museum
where country is not null
group by country
order by no_of_museums desc),
total_city as(
Select City, count(*) as no_of_museums
from museum
where city is not null
group by City
order by no_of_museums desc),
all_country as(
Select * from total_country
where no_of_museums = (Select max(no_of_museums) from total_country)),
all_city as(
Select * from total_city
where no_of_museums = (Select max(no_of_museums) from total_city))
Select (select group_concat(country separator ',') from all_country) as countries,
       (select group_concat(city separator ',') from all_city) as cities;
  
  
-- Identify the artist and the museum where the most expensive and least expensive
-- painting is placed. Display the artist name, sale_price, painting name, museum
-- name, museum city and canvas label

Select work_id, size_id, max(sale_price) expensive
from product_size
group by size_id, work_id
order by expensive desc
limit 1;

Select work_id, size_id, min(sale_price) expensive
from product_size
group by size_id, work_id
order by expensive asc
limit 1;

Select w.name, c.label, a.full_name, m.name, m.city, max(sale_price) 
as most_expensive
from product_size p inner join work w
on p.work_id = w.work_id
inner join canvas_size c on
c.size_id = p.size_id
inner join artist a on
a.artist_id = w.artist_id
inner join museum m on
m.museum_id = w.museum_id
group by w.name, c.label, a.full_name, m.name, m.city
order by most_expensive desc
limit 1;

with most_expensive as(
Select work_id, size_id, max(sale_price) expensive
from product_size
group by size_id, work_id
order by expensive desc
limit 1),
-- select museum_id, artist_id from work
-- where work_id = (select work_id from most_expensive);
least_expensive as(
Select work_id, size_id, min(sale_price) expensive
from product_size
group by size_id, work_id
order by expensive asc
limit 1)
Select a.full_name, me.expensive, w.name, m.name, m.city, c.label
from work w inner join artist a on a.artist_id = w.artist_id
inner join museum m on m.museum_id = w.museum_id
inner join most_expensive me on me.work_id = w.work_id
inner join canvas_size c on c.size_id = me.size_id
Union
Select a.full_name, le.expensive, w.name, m.name, m.city, c.label
from work w inner join artist a on a.artist_id = w.artist_id
inner join museum m on m.museum_id = w.museum_id
inner join least_expensive le on le.work_id = w.work_id
inner join canvas_size c on c.size_id = le.size_id;

-- Which country has the 5th highest no of paintings?
Select m.country, count(w.work_id) as max_painting
from work w inner join museum m
on w.museum_id = m.museum_id
group by m.country
order by max_painting desc
limit 1
offset 4;

-- Which are the 3 most popular and 3 least popular painting styles?
with most_popular as(
Select style, count(*) as popular from work
where style is not null
group by style
order by popular desc
limit 3),
least_popular as(
Select style, count(*) as popular from work
where style is not null
group by style
order by popular
limit 3)
Select style, 'most3_popular' as popular from most_popular
UNION
Select style, 'least3_popular' as popular from least_popular;

-- Which artist has the most no of Portraits paintings outside USA?. Display artist name, 
-- no of paintings and the artist nationality.
Select a.full_name, a.nationality, count(*) as no_of_paintings
from artist a inner join work w
on a.artist_id = w.artist_id inner join museum m
on m.museum_id = w.museum_id inner join subject s
on w.work_id = s.work_id
where m.country != 'USA' and s.subject = 'Portraits'
group by a.full_name, a.nationality
order by no_of_paintings desc
limit 1;

with no_usa as(
Select * from museum where country != 'USA'),
portrait as(
Select * from subject where subject = 'Portraits')
Select a.full_name, a.nationality, p.subject, nu.country
















    
    












