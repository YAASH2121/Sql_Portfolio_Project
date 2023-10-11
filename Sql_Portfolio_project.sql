Use yashdb
drop table Employee1



CREATE TABLE sales (
  "customer_id" VARCHAR(1),
  "order_date" DATE,
  "product_id" INTEGER
);


INSERT INTO sales
  ("customer_id", "order_date", "product_id")
VALUES
  ('A', '2021-01-01', '1'),
  ('A', '2021-01-01', '2'),
  ('A', '2021-01-07', '2'),
  ('A', '2021-01-10', '3'),
  ('A', '2021-01-11', '3'),
  ('A', '2021-01-11', '3'),
  ('B', '2021-01-01', '2'),
  ('B', '2021-01-02', '2'),
  ('B', '2021-01-04', '1'),
  ('B', '2021-01-11', '1'),
  ('B', '2021-01-16', '3'),
  ('B', '2021-02-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-07', '3');


CREATE TABLE menu (
  "product_id" INTEGER,
  "product_name" VARCHAR(5),
  "price" INTEGER
);

INSERT INTO menu
  ("product_id", "product_name", "price")
VALUES
  ('1', 'sushi', '10'),
  ('2', 'curry', '15'),
  ('3', 'ramen', '12');

CREATE TABLE members (
  "customer_id" VARCHAR(1),
  "join_date" DATE
);

INSERT INTO members
  ("customer_id", "join_date")
VALUES
  ('A', '2021-01-07'),
  ('B', '2021-01-09');

select * from sales
select * from members
select * from menu


//What is the total amount each customer spent at the restaurant?
select m.customer_id,SUM(b.price) as Total_spend from sales as m 
join menu b on m.product_id = b.product_id
group by customer_id


//How many days has each customer visited the restaurant?
select customer_id,COUNT(distinct order_date) as Visited_days from sales
group by customer_id

//What was the first item from the menu purchased by each customer?
with final as  ( 
select s.*,m.product_name,
rank() over (partition by customer_id order by order_date) as ranking
from sales as s
join menu as m 
on s.product_id = m.product_id)
select * from final where ranking=1;

//What is the most purchased item on the menu and how many times was it purchased by all customers?
select m.product_name,COUNT(m.product_id) as most_purchase_item from sales as s
join menu as m on s.product_id = m.product_id 
group by m.product_name
order by COUNT(m.product_id) desc

//Which item was the most popular for each customer?
with final as (
select s.customer_id,m.product_name,count(*) as total
from sales as s 
join menu as m on s.product_id = m.product_id
group by s.customer_id,m.product_name)
select customer_id,product_name  ,
rank() over(partition by customer_id order by total desc) as ranking
from final


//Which item was purchased just after the customer became a member?
with finals as (
select s.* ,m.customer_id as customerid,m.join_date,
rank() over(partition by s.customer_id order by order_date) as ranking,c.product_name
from sales as s
left join members as m
on s.customer_id = m.customer_id
join menu as c 
on s.product_id = c.product_id 
where s.order_date >= m.join_date )
select customer_id,ranking,product_name from finals where ranking = 1




//Which item was purchased just before the customer became a member?
select s.* ,m.customer_id as customerid,m.join_date,
rank() over(partition by s.customer_id order by order_date) as ranking,c.product_name
from sales as s
left join members as m
on s.customer_id = m.customer_id
join menu as c 
on s.product_id = c.product_id 
where s.order_date < m.join_date


//What is the total items and amount spent for each member before they became a member?//
select s.customer_id,SUM(price) sum_price,count(m.product_id) total_amount from sales as s join menu as m on s.product_id = m.product_id left join members as c on s.customer_id = c.customer_id
where s.order_date < c.join_date
group by s.customer_id

//If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
with points as (
select s.customer_id,s.order_date,m.price,m.product_name,
case when product_name = 'sushi' then 2*m.price 
else m.price end as newprice
from sales as s
join menu as m on s.product_id = m.product_id)

select customer_id,sum(newprice)*10 from points
group by customer_id








