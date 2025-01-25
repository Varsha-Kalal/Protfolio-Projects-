CREATE DATABASE ZOMATO_PROJECT;

CREATE TABLE goldusers_signup(userid integer,gold_signup_date date); 

--DEFAULT FORMAT OF DATE IN MYSQL IS YYYY-MM-DD
INSERT INTO goldusers_signup(userid,gold_signup_date) 
 VALUES (1,'2017-09-22'),
(3,'2017-09-22');

CREATE TABLE users(userid integer,signup_date date); 

INSERT INTO users(userid,signup_date) 
 VALUES (1,'2014-09-02'),
(2,'2015-01-15'),
(3,'2014-04-11');

drop table if exists sales;
CREATE TABLE sales(userid integer,created_date date,product_id integer); 

INSERT INTO sales(userid,created_date,product_id) 
 VALUES 
 (1,'2017-04-19',2),
(3,'2019-12-18',1),
(2,'2020-07-20',3),
(1,'2019-10-23',2),
(1,'2018-03-19',3),
(3,'2016-12-20',2),
(1,'2016-11-09',1),
(1,'2016-05-20',3),
(2,'2017-09-24',1),
(1,'2017-03-11',2),
(1,'2016-03-11',1),
(3,'2016-11-10',1),
(3,'2017-12-07',2),
(3,'2016-12-15',2),
(2,'2017-11-08',2),
(2,'2018-09-10',3);



drop table if exists product;
CREATE TABLE product(product_id integer,product_name text,price integer); 

INSERT INTO product(product_id,product_name,price) 
 VALUES
(1,'p1',980),
(2,'p2',870),
(3,'p3',330);


select * from sales;
select * from product;
select * from goldusers_signup;
select * from users;

--1. WHAT IS THE TOTAL AMOUNT EACH CUSTOMER SPENT ON ZOMATO 
SELECT S.userid, SUM(P.price) AS total_spent
FROM sales S
LEFT JOIN product P
on S.product_id = P.product_id
GROUP BY S.userid 
ORDER BY S.userid;

--2. how many distinct days customer visited zomato 
SELECT userid, COUNT(DISTINCT created_date) AS Count_of_Visits 
FROM sales 
GROUP BY userid;

--3. what was the frist product purchased by each customer 
WITH first_purchased AS(
SELECT userid, product_id, created_date, ROW_NUMBER() OVER(PARTITION BY userid ORDER BY created_date ASC) AS first_purchased_date 
FROM sales 
ORDER BY userid ASC
)
SELECT userid, product_id, created_date 
FROM first_purchased 
WHERE first_purchased_date = 1
ORDER BY created_date;

--4. what is the most purchased item in the menu and how many times was it purchased by all customer

SELECT userid, count(product_id) AS most_purchased 
FROM sales 
WHERE product_id =(
SELECT product_id
FROM sales 
GROUP BY product_id 
ORDER BY count(product_id) DESC
LIMIT 1)
GROUP BY userid;

--5. Which item was the most favourite item for each user
WITH countofproducts AS(
SELECT userid, product_id, count(product_id) AS total_count
FROM sales
GROUP BY userid, product_id),
rankoncount AS(
SELECT *, ROW_NUMBER() OVER(PARTITION BY userid ORDER BY total_count DESC) AS rnk
FROM countofproducts)
SELECT userid, product_id, total_count, rnk
FROM rankoncount
WHERE rnk =1;

--6. which item purchased first after they become a member
WITH rnkforcreateddate AS(
SELECT S.*, G.gold_signup_date, ROW_NUMBER() OVER(PARTITION BY userid ORDER BY created_date ASC) AS rnk 
FROM goldusers_signup G
JOIN sales S ON S.userid = G.userid 
where S.created_date>= G.gold_signup_date
)
SELECT userid, created_date, product_id, gold_signup_date, rnk
FROM rnkforcreateddate
WHERE rnk =1;

--7. which item was purchased just before the customer become a member
WITH rnkforcreateddate AS(
SELECT S.*, G.gold_signup_date, ROW_NUMBER() OVER(PARTITION BY userid ORDER BY created_date DESC) AS rnk 
FROM goldusers_signup G
JOIN sales S ON S.userid = G.userid 
where S.created_date< G.gold_signup_date
)
SELECT userid, created_date, product_id, gold_signup_date, rnk
FROM rnkforcreateddate
WHERE rnk =1;

--8.What is the orders and amount spent by each member before they become member
SELECT s.userid, SUM(p.price) AS total_amount_spent, count(s.created_date) as count_of_orders
FROM sales s
JOIN product p on s.product_id = p.product_id 
join goldusers_signup g on s.userid = g.userid
WHERE s.created_date < g.gold_signup_date
GROUP BY s.userid 
ORDER BY s.userid;

/* 9. if buying each product generates points e.g 5rs = 2 zomato points and each product has different purchasing points 
for e.g p1 5rs = 1 zomato point for p2 10rs= 5 zomato points and p3 5rs = 1 zomato point calculate points collected by each customer and for which product most points 
were collected till now.
calculate points collected by each customer and for which prodcut most points were collected till now */
















