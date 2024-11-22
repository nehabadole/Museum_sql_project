# Paintings Museum Data Analysis using SQL

## Objective

''' sql query to create DB & fetch tables

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
'''

''' sql query to Fetch all the paintings which are not displayed on any museums?

Select work_id, name
from work 
where museum_id is null; '''

''' sql query for Are there museums without any paintings?

Select m.museum_id, w.work_id, w.name
from museum m
Inner Join work w
On
m.museum_id = w.museum_id
where work_id is null; '''

''' sql query for How many paintings have an asking price of more than their regular price?
Select count(work_id), size_id
from product_size
where sale_price > regular_price
group by size_id; 

Select count(work_id)
from product_size
where sale_price > regular_price; '''

''' sql query to Identify the paintings whose asking price is less than 50% of its regular price
Select work_id, size_id from product_size
where sale_price < 0.5 * regular_price; '''

''' sql query Which canva size costs the most?
Select size_id, sum(sale_price) as total_sale_price
from product_size
group by size_id
order by total_sale_price desc
limit 1; '''

''' sql query Fetch the top 10 most famous painting subject
select subject, count(subject) as Total
from subject
group by subject
order by Total desc;
'''

''' sql query to Identify the museums which are open on both Sunday and Monday. Display museum name, city.
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
'''

''' sql query to Delete duplicate records from work, product_size, subject and image_link tables
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
'''

''' sql query to Identify the museums with invalid city information in the given dataset
Select * from museum 
where city regexp '^[0-9]';

Update museum
set city = NULL
where city regexp '^[0-9]';
'''

''' sql query Museum_Hours table has 1 invalid entry. Identify it and remove it.
Update museum_hours 
set day = 'Thursday'
where day = 'Thusday';
'''

''' sql query How many museums are open every single day?
Select count(museum_id) as museum_id_count from 
(Select museum_id, count(day) as museum_open_days
from museum_hours
group by museum_id
having museum_open_days = 7) as open_days;
'''

''' sql query Which are the top 5 most popular museum? (Popularity is defined based on most no of paintings in a museum)
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
'''

''' sql query Who are the top 5 most popular artist? (Popularity is defined based on most no of paintings done by an artist)
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
'''






