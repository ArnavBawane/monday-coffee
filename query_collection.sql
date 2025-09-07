--Monday Coffee query_collection

select * from city;
SELECT * FROM products;
SELECT * FROM customers;
select * from sales;


--Q1.
--Yearly Sales Trend
--Total sales per year.

select extract(year from SALE_DATE) as year,
      sum(total) as total_by_year
from SALES
group by extract(year from SALE_DATE)
order by year;


--Q2.
--Product Category Sales Performance
--Total sales grouped by product category.

select p.product_name, 
       sum(s.total) as sales 
from PRODUCTS p 
join sales s
 on s.PRODUCT_ID = p.PRODUCT_ID
group by p.PRODUCT_NAME
order by sales desc;


--Q3.
--Coffee Consumers Count
--How many people in each city are estimated to consume coffee, given that 25% of the population does?

SELECT 
	city_name,
	ROUND(
	(population * 0.25)/1000000, 
	2) as coffee_consumers_in_millions,
	city_rank
FROM city
ORDER BY 2 DESC;


--Q4.
--Sales Count for Each Product
--How many units of each coffee product have been sold?

select 
      p.product_id ,
      p.product_name,
      count(s.total) as unit_per_product
from PRODUCTS p JOIN SALES s
  on p.PRODUCT_ID = s.PRODUCT_ID
group by p.PRODUCT_ID,p.PRODUCT_NAME
order by p.PRODUCT_ID asc;


--Q5.
--total sale per month

SELECT 
    EXTRACT(YEAR FROM s.sale_date) AS year,
    EXTRACT(MONTH FROM s.sale_date) AS month,
    SUM(s.total) AS total_sales
FROM sales s
GROUP BY EXTRACT(YEAR FROM s.sale_date), EXTRACT(MONTH FROM s.sale_date)
ORDER BY year, month;


--Q6
--top 3 cites by sale

select ci.city_name,
       sum(s.total) as total_sale
from SALES s
join CUSTOMERS c
 on s.CUSTOMER_ID = c.CUSTOMER_ID
 join CITY ci
 on c.CITY_ID = c.CITY_ID
 group by ci.CITY_NAME
ORDER by total_sale desc
fetch FIRST 3 ROWS ONLY;


--7.
--Top 10 Customers
--Top 10 customers based on total spend.
select * from
  (select c.customer_id, sum(s.total) as total
  from CUSTOMERS c
  join SALES s
   on c.customer_id = s.customer_id
   GROUP BY c.customer_id
   order by total desc)
where rownum <= 10;


--Q8.
--Peak Sales Day
--Which date had the highest total sales?

select sale_date,
       sum(total) as total_sale
from SALES
group by SALE_DATE
order by total_sale desc
fetch FIRST 1 ROW ONLY;


--Q9.
--Total Revenue from Coffee Sales
--What is the total revenue generated from coffee sales across all cities in the last quarter of 2023?

select 
      c.city_name,
      sum(s.TOTAL) as revenue       
from CITY c join CUSTOMERS cu
  on c.CITY_ID = cu.CITY_ID
join SALES s
  on cu.CUSTOMER_ID = s.CUSTOMER_ID
where EXTRACT(YEAR from s.sale_date) = 2023 
  and  TO_CHAR(s.sale_date, 'Q') = '4'
group by c.city_name
order by 2 desc;


-- Q.10
-- Average Sales Amount per City
-- What is the average sales amount per customer in each city?
--- firs sub quary gives total sales by each costemer
--- and base on that we use sub quary table's tota_sale column for avrage sale by per customer
--and then we group by it with city name
--its give us the total of average sale by city name


select c.city_name,
       round(avg(cs.total_sales),2) as avg_sale  
from city  c join customers cu 
  on c.city_id = cu.city_id
 join
(SELECT 
        customer_id, 
        SUM(total) AS total_sales
FROM sales
GROUP BY customer_id) cs
  on cu.customer_id = cs.customer_id
group by c.CITY_NAME
order BY avg_sale desc;   
  


-- Q.11
-- Customer Segmentation by City
-- How many unique customers are there in each city who have purchased coffee products?

select ci.city_name,
       count(distinct(c.customer_id)) as customer     
from  city ci 
join customers c
on c.city_id = ci.city_id
join sales s
on s.customer_id = c.customer_id
where s.PRODUCT_ID in (1,2,3,4,5,6,7,8,9,10,11,12,13,14)
group by ci.city_name
order BY 2 DESC;



--Q12.
--Sales Contribution by City (%)
--Percentage contribution of each city to total sales.

select ci.city_name,
       round(sum(s.total)*100/(select sum(total) from sales),2) as sales_percentage
from city ci
JOIN customers c
  ON c.city_id = ci.city_id
JOIN sales s
  ON s.customer_id = c.customer_id
group by ci.city_name  
order by sales_percentage desc;
  
-- -- Q.13
-- City Population and Coffee Consumers (25%)
-- Provide a list of cities along with their populations and estimated  coffee consumers.
-- return city_name, total current cx, estimated coffee consumers (25%)
-- firs find cofee consumer population with 0.25
--after creat second table with customer we coun total customer per city

WITH city_table 
AS
 (
select city_name,
      round((population*0.25)/1000000,2) as coffe_consumers
from CITY
          ),
customer 
as
    (
     select c.city_name,
           count(distinct(cu.customer_id))as cu_id
     from CITY c join CUSTOMERS cu
     on cu.CITY_ID = c.CITY_ID
     group by c.CITY_NAME
    order by 2 desc
)
select city_table.city_name,
       city_table.coffe_consumers,
      customer.cu_id
from city_table JOIN customer
on city_table.city_name = customer.city_name;


-- -- Q14
-- Top Selling Products by City
-- What are the top 3 selling products in each city based on sales volume?
select * FROM
(select  c.city_name,
        p.PRODUCT_NAME,
        count(sale_id) as total_order,
        DENSE_RANK()OVER(PARTITION by c.city_name ORDER by count(sale_id)desc) as rank
from CITY c JOIN CUSTOMERS
on c.CITY_ID = CUSTOMERS.CITY_ID
join SALES s 
on  CUSTOMERS.CUSTOMER_ID = s.CUSTOMER_ID
join PRODUCTS p
on s.PRODUCT_ID = p.PRODUCT_ID
group by c.city_name,p.PRODUCT_NAME)
where rank <= 3;



--Q15. Highest Spending Customer in Each City
--Find the customer who spent the most in every city.

SELECT city_name, customer_name, total_sales
FROM (
    SELECT ci.city_name,
           c.customer_name,
           SUM(s.total) AS total_sales,
           ROW_NUMBER() OVER (
               PARTITION BY ci.city_name
               ORDER BY SUM(s.total) DESC
           ) AS rn
    FROM city ci
    JOIN customers c
      ON c.city_id = ci.city_id
    JOIN sales s
      ON s.customer_id = c.customer_id
    GROUP BY ci.city_name, c.customer_name
)
WHERE rn = 1;



--Q.16
--Average Sales per Category per Month

select p.product_name,
      to_char(s.sale_date, 'yyyy-mm') as month,
       avg(s.total) as avg_sales
from sales s
join PRODUCTS p
  on s.PRODUCT_ID = p.PRODUCT_ID
group by p.PRODUCT_NAME,to_char(s.sale_date, 'yyyy-mm')
order by avg_sales desc;
       


/*
-- Recomendation
City 1: Pune
  1.sales contribution by city is high 20%
	2.Highest total revenue.
	3.Average sales per customer is also high.

City 2: Delhi
	1.Highest estimated coffee consumers at 7.7 million.
	2.Highest total number of customers, which is 68.

City 3: Jaipur
	1.Highest number of customers, which is 69.
  2. comes in top 3 city by sales

	3.Average sales per customer is better at 11.6k. */


