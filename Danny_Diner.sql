CREATE TABLE sales 
(  
customer_id VARCHAR(1),  
order_date DATE,  
product_id INTEGER);   
INSERT INTO sales  
(customer_id, order_date, product_id)
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
CREATE TABLE menu 
(
product_id INTEGER,  
product_name VARCHAR(5),  
price INTEGER); 
INSERT INTO menu  
(product_id, product_name, price)
VALUES  
('1', 'sushi', '10'),  
('2', 'curry', '15'),  
('3', 'ramen', '12');   
CREATE TABLE members 
(
customer_id VARCHAR(1),  
join_date DATE); 
INSERT INTO members  
(customer_id, join_date)
VALUES  
('A', '2021-01-07'),  
('B', '2021-01-09');

------------------------
--CASE STUDY QUESTIONS--
------------------------

--1. What is the total amount each customer spent at the restaurant?
--each cust.> spending
SELECT
    s.customer_id,
    SUM(m.price) spending
FROM sales s
JOIN menu m
    ON s.product_id = m.product_id
GROUP BY s.customer_id;

--2. How many days has each customer visited the restaurant?
--each cust>total days
--COUNT(DISTINCT), a customer can visit twice on the same day
SELECT
    customer_id,
    COUNT(DISTINCT(order_date)) days_visited
FROM sales
GROUP BY customer_id;

--3. What was the first item from the menu purchased by each customer?
--each cust> first item (each cust> item purchased> order date, rank)
--a customer can order 2 items on the same day:
--use DENSE_RANK instead of ROW_NUMBER or RANK as the order_date is not time stamped,
--GROUP BY customer_id, product_name
WITH cte_sales AS
	(SELECT s.customer_id,
        s.order_date,
     	s.product_id,
        m.product_name,
           DENSE_RANK() OVER (
             PARTITION BY s.customer_id
             ORDER BY s.order_date) rank
    FROM sales s
    JOIN menu m
        ON s.product_id = m.product_id)

SELECT
    s.customer_id,
    m.product_name
FROM cte_sales s
JOIN menu m
	ON s.product_id = m.product_id
WHERE rank = 1
GROUP BY s.customer_id,
	m.product_name;

--4. What is the most purchased item on the menu and how many times was it purchased by all customers?
--most_purchased, times
SELECT
    m.product_name,
    COUNT(s.product_id) sales_count
FROM sales s
JOIN menu m
    ON s.product_id = m.product_id
GROUP BY m.product_name
ORDER BY sales_count DESC
LIMIT 1;

--5. Which item was the most popular for each customer?
--each cust> most popular item (product name, rank)
--customer can order items in the same amount, so customer_id, product_name
WITH cte_top_sales AS 
(SELECT
    s.customer_id,
    m.product_name,
    COUNT(s.product_id) as order_count,
    DENSE_RANK() OVER (
	 PARTITION BY s.customer_id
	 ORDER BY COUNT(s.product_id) DESC) rank
    FROM sales s
    JOIN menu m
        ON s.product_id = m.product_id
    GROUP BY s.customer_id, m.product_name)

SELECT
    customer_id,
    product_name,
    order_count
FROM cte_top_sales
WHERE rank = 1
GROUP BY s.customer_id, m.product_name;

--6. Which item was purchased first by the customer after they became a member?
--member> first_item (each member> item_purchased after membership, order date, rank)
WITH cte_member_sales AS
(SELECT
    s.customer_id,
    s.order_date,
    m2.join_date,
    s.product_id,
    DENSE_RANK() OVER(
       PARTITION BY s.customer_id
       ORDER BY s.order_date) rank
 FROM sales s
 JOIN members m2
    ON s.customer_id = m2.customer_id
 WHERE s.order_date >= m2.join_date
 GROUP BY s.customer_id, s.product_id)

SELECT
    m2.customer_id,
    m.product_name
FROM cte_member_sales m2
JOIN menu m
    ON m2.product_id = m.product_id
WHERE rank = 1
GROUP BY m2.customer_id, m.product_name;


--7. Which item was purchased just before the customer became a member?
--just before = first purchase
WITH cte_prior_membership_sales AS
(SELECT
     s.customer_id,
     s.order_date,
     m2.join_date,
     s.product_id,
     DENSE_RANK() OVER(
       PARTITION BY s.customer_id
       ORDER BY s.order_date DESC) rank
 FROM sales s
 JOIN members m2
 	ON s.customer_id = m2.customer_id
    WHERE s.order_date < m2.join_date
    GROUP BY s.customer_id, s.product_id)

SELECT
    m2.customer_id,
    m.product_name
FROM cte_prior_membership_sales m2
JOIN menu m
    ON m2.product_id = m.product_id
WHERE rank = 1
GROUP BY m2.customer_id, m.product_name;

--8. What is the total items and amount spent for each member before they became a member?
--each member> before membership, total items, spending
SELECT
    s.customer_id,
    COUNT(DISTINCT(m.product_id)) items_purchased,
    SUM(m.price) spending
FROM sales s
JOIN members m2
    ON s.customer_id = m2.customer_id
JOIN menu m
    ON s.product_id = m.product_id
WHERE s.order_date < m2.join_date
GROUP BY s.customer_id;

--9. If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
--each cust> points, if>> CASE WHEN, THEN, ELSE
WITH cte_points_multiplier AS
(SELECT *,
    CASE
 	WHEN product_name = "sushi" THEN price * 20
        ELSE price * 10
 	END points
 FROM menu)

SELECT
    s.customer_id,
    SUM(p.points) total_points
FROM cte_points_multiplier p
JOIN sales s
	ON s.product_id = p.product_id
GROUP BY s.customer_id;


--10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?
--sushi> 2x points, member (within first week, including join date) > 2x points

WITH cte_membership AS (
    SELECT
  	customer_id,
  	join_date,
        DATE(join_date, '+ 6 DAY') valid_date
    FROM members)
	
SELECT 
    m2.customer_id,
    SUM(CASE
	 WHEN m.product_name = 'sushi' THEN m.price * 2 * 10
	 WHEN s.order_date BETWEEN m2.join_date AND m2.valid_date THEN m.price * 2 * 10
     ELSE m.price * 10 
     END) points
FROM cte_membership m2
JOIN sales s
	ON s.customer_id = m2.customer_id
JOIN menu m
	ON m.product_id = s.product_id
WHERE s.order_date <= '2021-01-31'
GROUP BY s.customer_id;

------------------------
--BONUS QUESTIONS-------
------------------------

-- Join All The Things
-- Recreate the table with: customer_id, order_date, product_name, price, member (Y/N)
SELECT
   s.customer_id,
   s.order_date,
   m.product_name,
   m.price,
   CASE
      WHEN m2.join_date <= s.order_date THEN 'Y'
      ELSE 'N'
      END member
FROM sales s
JOIN menu m
   ON s.product_id = m.product_id
JOIN members m2
   ON s.customer_id = m2.customer_id;

-- Rank All The Things
-- Recreate the table with: customer_id, order_date, product_name, price, member (Y/N), ranking(null/123)
WITH cte_summary AS 
(SELECT 
    s.customer_id, 
    s.order_date, 
    m.product_name, 
    m.price,
    CASE
	WHEN m2.join_date > s.order_date THEN 'N'
	WHEN m2.join_date <= s.order_date THEN 'Y'
	ELSE 'N'
        END member
FROM sales s
JOIN menu m
   ON s.product_id = m.product_id
JOIN members m2
   ON s.customer_id = m2.customer_id)

SELECT *,
       CASE
    	   WHEN member = 'N' THEN NULL
   	   ELSE
           RANK () OVER(
               PARTITION BY customer_id, member
               ORDER BY order_date) 
           END rank
FROM cte_summary;
