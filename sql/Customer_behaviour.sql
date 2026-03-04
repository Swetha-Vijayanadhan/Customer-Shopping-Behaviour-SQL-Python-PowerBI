--Q1) what is the total revenue genearted by make and female
select gender, sum(purchase_amount) as revenue 
from customer_data
group by gender

--Q2) which customer used a discount but still spent more than the average purchase amount
select * from customer_data

select customer_id, purchase_amount
from customer_data
where discount_applied = 'Yes' and purchase_amount >= (select avg(purchase_amount) from customer_data) 

--Q3) which are the top 5 products  with the highest average review rating

select item_purchased, round(avg(review_rating::numeric),2) as average_prod_rating
from customer_data
group by item_purchased
order by avg(review_rating) desc
limit 5

--4)compare the average purchase amount between standard and express shipping

select round(avg(purchase_amount),2), shipping_type from customer_data
where shipping_type in ('Standard', 'Express')
group by shipping_type

--Q5)Do Subscribed Customers spend more, compare avg spend and total revenue bet subscribers and non-subscribers

select subscription_status,
count(customer_id) as customer,
round(avg(purchase_amount),2) as avg_spend, round(sum(purchase_amount),2) as revenue
from customer_data
group by subscription_status
order by avg_spend, revenue desc

--Q6) which 5 products has highest percentage of purchases with discount applied

SELECT item_purchased,
       ROUND(
         100.0 * SUM(CASE WHEN discount_applied = 'Yes' THEN 1 ELSE 0 END) 
         / COUNT(*),
         2
       ) AS discount_rate
FROM customer_data
GROUP BY item_purchased
ORDER BY discount_rate DESC
LIMIT 5;

--Q7) segment customers into new, returning and loyal based on their total no of previous purchases ,
--and show the count of each segmnet
 select * from customer_data

with customer_type as (
select customer_id, previous_purchases,
CASE 
     WHEN previous_purchases = 1 THEN 'New'
	 WHEN previous_purchases between 2 and 10 then 'returning'
	 else 'Loyal'
	 End as customer_segment
FROM customer_data
)

select customer_segment, count(*) as "no of customers"
FROM CUSTOMER_TYPE
GROUP BY CUSTOMER_SEGMENT

--Q8) What are the top 3 most purchase products within ewach category
with item_count as (
select category, item_purchased,
count(customer_id) as total_orders,
row_number() over(partition by category order by count(customer_id) desc) as item_rank
from customer_data
group by category, item_purchased
)
select item_rank, category, item_purchased, total_orders
from item_count
where item_rank <=3;

--Q9) Are customers who are repeat buyers (more than 5 previous purchase) also likely to subscribe
select subscription_status,
count(customer_id) as repeat_buyers
from customer_data
where previous_purchases > 5
group by subscription_status

--Q10) What is the revenue contribution of each age group
select sum(purchase_amount) as revenue, age_group
from customer_data
group by age_group
order by revenue desc
