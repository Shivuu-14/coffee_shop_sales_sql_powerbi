use coffee_shop_sales_db;
select * from coffee_shop_sales;
describe coffee_shop_sales;
update coffee_shop_sales
set transaction_date = str_to_date(transaction_date, '%d-%m-%Y');

alter table coffee_shop_sales
modify column transaction_date date;

update coffee_shop_sales
set transaction_time = str_to_date(transaction_time, '%H:%i:%s');

alter table coffee_shop_sales
modify column transaction_time time;

alter table coffee_shop_sales
change column ï»¿transaction_id transaction_id int;

describe coffe_shop_sales;

-- calculate sales for each respective month
select * from coffee_shop_sales;
select sum(unit_price * transaction_qty) as total_sales
from coffee_shop_sales
where  month(transaction_date) = 5;  -- may month

-- TOTAL SALES KPI - MOM DIFFERENCE AND MOM GROWTH

SELECT 
    MONTH(transaction_date) AS month,
    ROUND(SUM(unit_price * transaction_qty)) AS total_sales,
    (SUM(unit_price * transaction_qty) - LAG(SUM(unit_price * transaction_qty), 1)
    OVER (ORDER BY MONTH(transaction_date))) / LAG(SUM(unit_price * transaction_qty), 1) 
    OVER (ORDER BY MONTH(transaction_date)) * 100 AS mom_increase_percentage
FROM 
    coffee_shop_sales
WHERE 
    MONTH(transaction_date) IN (4, 5) -- for months of April and May
GROUP BY 
    MONTH(transaction_date)
ORDER BY 
    MONTH(transaction_date);

-- calculate total orders for each month/ current month
select count(transaction_id) as total_orders
from coffee_shop_sales
where month(transaction_date) = 5;

-- TOTAL ORDERS KPI - MOM DIFFERENCE AND MOM GROWTH
select 
month(transaction_date) as month,
 round(count(transaction_id)) as total_orders,
(count(transaction_id) - lag(count(transaction_id), 1)
over (order by month(transaction_date)))/ lag(count(transaction_id), 1)
over (order by month(transaction_date)) * 100 as increased_percentage
from coffee_shop_sales
where month(transaction_date) in(4, 5)
group by month(transaction_date)
order by month(transaction_date);

-- calculate total quantity of orders for each month/ current month
select sum(transaction_qty) as total_quantity_sold
from coffee_shop_sales
where month(transaction_date) = 5; -- may month

-- TOTAL QUANTITY SOLD KPI - MOM DIFFERENCE AND MOM GROWTH
select month(transaction_date) as month,
round(sum(transaction_qty)) as total_quantity_sold,
(sum(transaction_qty) - lag(sum(transaction_qty),1)
over (order by month(transaction_date)))/ lag(sum(transaction_qty),1)
over (order by month(transaction_date)) * 100 as increased_percentage
from coffee_shop_sales
where month(transaction_date) in (4,5)
group by month(transaction_date)
order by month(transaction_date);

-- CALENDAR TABLE – DAILY SALES, QUANTITY and TOTAL ORDERS
select concat(round(sum(unit_price * transaction_qty)/1000,1) ,'K') as total_sales,
concat(round(sum(transaction_qty)/1000,1), 'K') as total_quantity_sold,
concat(round(count(transaction_id)/1000,1), 'K') as total_orders
from coffee_shop_sales
where transaction_date = '2023-05-14';

-- SALES ANALYSIS BY WEEKENDS AND WEEKDAYS
select 
case when dayofweek(transaction_date) in(1,7) then 'weekends'
else 'weekdays'
end as day_type,
concat(round(sum(unit_price*transaction_qty)/1000,1), 'K') as total_sales
from coffee_shop_sales
where month(transaction_date) = 5
group by case when dayofweek(transaction_date) in(1,7) then 'weekends'
else 'weekdays'
end ;


-- SALES ANALYSIS BY STORE LOCATION 
select store_location,
concat(round(sum(unit_price*transaction_qty)/1000, 2), 'K') as total_sales
from coffee_shop_sales 
where month(transaction_date) = 5
group by store_location
order by total_sales desc;

-- DAILY SALES ANALYSIS WITH AVERAGE LINE
select concat(round(avg(total_sales)/1000, 1), 'K') as average_sales
from(
select sum(unit_price * transaction_qty) as total_sales
from coffee_shop_sales
where month(transaction_date) = 5 -- may month
group by transaction_date) as internal_query;

-- SALES ANALYSIS FOR EACH DAY OF MONTH
select day(transaction_date) as day_of_month,
concat(round(sum(unit_price*transaction_qty)/1000,2), 'K') as total_sales
from coffee_shop_sales
where month(transaction_date) = 5
group by day_of_month
order by day_of_month;

-- COMPARING DAILY SALES WITH AVERAGE SALES 
--  IF GREATER THAN “ABOVE AVERAGE” and LESSER THAN “BELOW AVERAGE”
select day_of_month,
case when total_sales > avg_sales then ' Above Average'
when total_sales< avg_sales then 'Above Average'
else 'Average'
end as sales_status ,
total_sales
from (
select
day(transaction_date) as day_of_month,
 concat(round(sum(unit_price*transaction_qty)/1000, 2), 'K') as total_sales,
 avg(sum(unit_price*transaction_qty)) over() as avg_sales
from coffee_shop_sales
where month(transaction_date) = 5
group by day_of_month)as sales_data
order by day_of_month;


-- SALES ANALYSIS BY PRODUCT CATEGORY
select product_category,
concat(round(sum(unit_price*transaction_qty)/1000, 1), 'K') as total_sales
from coffee_shop_sales
where month(transaction_date) = 5
group by product_category
order by total_sales desc;

-- -- SALES ANALYSIS BY PRODUCT TYPE
select  product_category, product_type,
concat(round(sum(unit_price*transaction_qty)/1000, 2), 'K') as total_sales
from coffee_shop_sales
where month(transaction_date) = 5 and product_category = 'Coffee'
group by product_type
order by total_sales desc;


-- SALES ANALYSIS BY DAYS AND HOURS
select concat(round(sum(unit_price*transaction_qty)/1000, 2), 'K') as total_sales,
sum(transaction_qty) as total_qty_sold,
count(transaction_id) as total_orders
from coffee_shop_sales
where month(transaction_date) = 5 and 
dayofweek(transaction_date) = 2 and
hour(transaction_time) = 8;

-- TO GET SALES FOR ALL HOURS FOR MONTH OF MAY
select 
hour(transaction_time) as hours,
sum(unit_price*transaction_qty) as total_sales
from coffee_shop_sales
where month(transaction_date) = 5
group by hours
order by total_sales desc;


-- TO GET SALES FROM MONDAY TO SUNDAY FOR MONTH OF MAY
select 
case when dayofweek(transaction_date) = 2 then 'Monday'
when dayofweek(transaction_date) = 3 then 'Tuesday'
when dayofweek(transaction_date) = 4 then 'Wednesday'
when dayofweek(transaction_date) = 5 then 'Thursday'
when dayofweek(transaction_date) = 6 then 'Friday'
when dayofweek(transaction_date) = 7 then 'Saturday'
else 'Sunday'
end as day_of_week,
round(sum(unit_price*transaction_qty)) as total_sales
from coffee_shop_sales
where month(transaction_date) = 5
group by 
case when dayofweek(transaction_date) = 2 then 'Monday'
when dayofweek(transaction_date) = 3 then 'Tuesday'
when dayofweek(transaction_date) = 4 then 'Wednesday'
when dayofweek(transaction_date) = 5 then 'Thursday'
when dayofweek(transaction_date) = 6 then 'Friday'
when dayofweek(transaction_date) = 7 then 'Saturday'
else 'Sunday'
end;
