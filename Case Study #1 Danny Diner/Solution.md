# Case Study #1: Danny's Diner

### 1. What is the total amount each customer spent at the restaurant?

````sql
SELECT
    s.customer_id,
    SUM(m.price) spending
FROM sales s
JOIN menu m
    ON s.product_id = m.product_id
GROUP BY s.customer_id;
````

#### Answer:
| customer_id | total_sales |
| ----------- | ----------- |
| A           | 76          |
| B           | 74          |
| C           | 36          |

- Customer A spent $76.
- Customer B spent $74.
- Customer C spent $36.

***

### 2. How many days has each customer visited the restaurant?

````sql
SELECT
    customer_id,
    COUNT(DISTINCT(order_date)) days_visited
FROM sales
GROUP BY customer_id;
````

#### Answer:
| customer_id | visit_count |
| ----------- | ----------- |
| A           | 4          |
| B           | 6          |
| C           | 2          |

- Customer A visited 4 times.
- Customer B visited 6 times.
- Customer C visited 2 times.

***

### 3. What was the first item from the menu purchased by each customer?

````sql
WITH cte_sales AS
	(SELECT s.customer_id,
        s.order_date,
     	s.product_id,
        m.product_name,
           DENSE_RANK() OVER (
             PARTITION BY s.customer_id
             ORDER BY s.order_date) ranks
    FROM sales s
    JOIN menu m
        ON s.product_id = m.product_id)

SELECT
    s.customer_id,
    m.product_name
FROM cte_sales s
JOIN menu m
	ON s.product_id = m.product_id
WHERE ranks = 1
GROUP BY s.customer_id,
	m.product_name;
````

#### Answer:
| customer_id | product_name | 
| ----------- | -------------|
| A           | curry        | 
| A           | sushi        | 
| B           | curry        | 
| C           | ramen        |

- There are two items on Customer A's first order: curry and sushi.
- As for Customer B, curry.
- As for Customer C, ramen.

***

### 4. What is the most purchased item on the menu and how many times was it purchased by all customers?

````sql
SELECT
    m.product_name,
    COUNT(s.product_id) sales_count
FROM sales s
JOIN menu m
    ON s.product_id = m.product_id
GROUP BY m.product_name
ORDER BY sales_count DESC
LIMIT 1;
````

#### Answer:
| most_purchased | product_name | 
| -------------- | ------------ |
| 8              | ramen        |


- Most purchased item on the menu by all customers is ramen which was bought 8 times in total.

***

### 5. Which item was the most popular for each customer?

````sql
WITH cte_top_sales AS 
(SELECT
    s.customer_id,
    m.product_name,
    COUNT(s.product_id) order_count,
    DENSE_RANK() OVER (
	 PARTITION BY s.customer_id
	 ORDER BY COUNT(s.product_id) DESC) ranks
    FROM sales s
    JOIN menu m
        ON s.product_id = m.product_id
    GROUP BY s.customer_id, m.product_name)

SELECT
    customer_id,
    product_name,
    order_count
FROM cte_top_sales
WHERE ranks = 1
GROUP BY customer_id, product_name;
````

#### Answer:
| customer_id | product_name | order_count |
| ----------- | ------------ |------------ |
| A           | ramen        |  3          |
| B           | sushi        |  2          |
| B           | curry        |  2          |
| B           | ramen        |  2          |
| C           | ramen        |  3          |

- Customer A and C's favourite item is ramen.
- Customer B enjoys all items on the menu equally.
- Ramen is the best seller of the restaurant.

***

### 6. Which item was purchased first by the customer after they became a member?

````sql
WITH cte_member_sales AS
(SELECT
    s.customer_id,
    s.order_date,
    m2.join_date,
    s.product_id,
    DENSE_RANK() OVER(
       PARTITION BY s.customer_id
       ORDER BY s.order_date) ranks
 FROM sales s
 JOIN members m2
    ON s.customer_id = m2.customer_id
 WHERE s.order_date >= m2.join_date
 GROUP BY s.customer_id, s.order_date, m2.join_date, s.product_id)

SELECT
    m2.customer_id,
    m.product_name
FROM cte_member_sales m2
JOIN menu m
    ON m2.product_id = m.product_id
WHERE ranks = 1
GROUP BY m2.customer_id, m.product_name;
````

#### Answer:
| customer_id || product_name |
| ----------- |-------------- |
| A           | curry         |
| B           | sushi         |

- After getting into membership,
- Customer A's first order is curry.
- As for Customer B, sushi.

***

### 7. Which item was purchased just before the customer became a member?

````sql
WITH cte_prior_membership_sales AS
(SELECT
     s.customer_id,
     s.order_date,
     m2.join_date,
     s.product_id,
     DENSE_RANK() OVER(
       PARTITION BY s.customer_id
       ORDER BY s.order_date DESC) ranks
 FROM sales s
 JOIN members m2
 	ON s.customer_id = m2.customer_id
    WHERE s.order_date < m2.join_date
    GROUP BY s.customer_id, s.order_date, m2.join_date, s.product_id)

SELECT
    m2.customer_id,
    m.product_name
FROM cte_prior_membership_sales m2
JOIN menu m
    ON m2.product_id = m.product_id
WHERE ranks = 1
GROUP BY m2.customer_id, m.product_name
ORDER BY m2.customer_id;
````

#### Answer:
| customer_id | product_name |
| ----------- |------------  |
| A           |  sushi       |
| A           |  curry       |
| B           |  sushi       |
- Just before becoming a member,
- Customer A’s last order is sushi and curry.
- As for Customer B, sushi.

***

### 8. What is the total items and amount spent for each member before they became a member?

````sql
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

````

#### Answer:
| customer_id | unique_menu_item | total_sales |
| ----------- | ---------------- |-----------  |
| A           | 2                |  25         |
| B           | 2                |  40         |

Just before getting into membership,
- Customer A spent $ 25 on 2 items.
- Customer B spent $40 on 2 items.

***

### 9. If each $1 spent equates to 10 points and sushi has a 2x points multiplier — how many points would each customer have?

````sql
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
````

#### Answer:
| customer_id | total_points | 
| ----------- | -------------|
| A           | 860          |
| B           | 940          |
| C           | 360          |
With multiplier point system, total points:
- for Customer A, 860.
- for Customer B, 940.
- for Customer C, 360.

***

### 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi — how many points do customer A and B have at the end of January?

````sql
WITH cte_membership AS (
    SELECT
  	customer_id,
  	join_date,
        DATE_ADD(join_date, INTERVAL 6 DAY) valid_date
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
GROUP BY s.customer_id
ORDER BY s.customer_id;
````

#### Answer:
| customer_id | total_points | 
| ----------- | ---------- |
| A           | 1370 |
| B           | 820 |

- Total points for Customer A is 1,370.
- Total points for Customer B is 820.

***

## BONUS QUESTIONS

### Join All The Things - Recreate the table with: customer_id, order_date, product_name, price, member (Y/N)

````sql
SELECT
   s.customer_id,
   s.order_date,
   m.product_name,
   m.price,
   CASE
      WHEN m2.join_date <= s.order_date THEN 'Y'
      ELSE 'N'
      END AS member
FROM sales s
LEFT JOIN menu m
   ON s.product_id = m.product_id
LEFT JOIN members m2
   ON s.customer_id = m2.customer_id;
 ````
 
#### Answer: 
| customer_id | order_date | product_name | price | member |
| ----------- | ---------- | -------------| ----- | ------ |
| A           | 2021-01-01 | sushi        | 10    | N      |
| A           | 2021-01-01 | curry        | 15    | N      |
| A           | 2021-01-07 | curry        | 15    | Y      |
| A           | 2021-01-10 | ramen        | 12    | Y      |
| A           | 2021-01-11 | ramen        | 12    | Y      |
| A           | 2021-01-11 | ramen        | 12    | Y      |
| B           | 2021-01-01 | curry        | 15    | N      |
| B           | 2021-01-02 | curry        | 15    | N      |
| B           | 2021-01-04 | sushi        | 10    | N      |
| B           | 2021-01-11 | sushi        | 10    | Y      |
| B           | 2021-01-16 | ramen        | 12    | Y      |
| B           | 2021-02-01 | ramen        | 12    | Y      |
| C           | 2021-01-01 | ramen        | 12    | N      |
| C           | 2021-01-01 | ramen        | 12    | N      |
| C           | 2021-01-07 | ramen        | 12    | N      |

***

### Rank All The Things - null ```ranking``` values for the records when customers are not yet part of the loyalty program.

````sql
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
        END AS member
FROM sales s
LEFT JOIN menu m
   ON s.product_id = m.product_id
LEFT JOIN members m2
   ON s.customer_id = m2.customer_id)

SELECT *,
       CASE
    	   WHEN member = 'N' THEN NULL
   	   ELSE
           RANK () OVER(
               PARTITION BY customer_id, member
               ORDER BY order_date) 
           END ranks
FROM cte_summary;

````

#### Answer: 
| customer_id | order_date | product_name | price | member | ranking | 
| ----------- | ---------- | -------------| ----- | ------ |-------- |
| A           | 2021-01-01 | sushi        | 10    | N      | NULL
| A           | 2021-01-01 | curry        | 15    | N      | NULL
| A           | 2021-01-07 | curry        | 15    | Y      | 1
| A           | 2021-01-10 | ramen        | 12    | Y      | 2
| A           | 2021-01-11 | ramen        | 12    | Y      | 3
| A           | 2021-01-11 | ramen        | 12    | Y      | 3
| B           | 2021-01-01 | curry        | 15    | N      | NULL
| B           | 2021-01-02 | curry        | 15    | N      | NULL
| B           | 2021-01-04 | sushi        | 10    | N      | NULL
| B           | 2021-01-11 | sushi        | 10    | Y      | 1
| B           | 2021-01-16 | ramen        | 12    | Y      | 2
| B           | 2021-02-01 | ramen        | 12    | Y      | 3
| C           | 2021-01-01 | ramen        | 12    | N      | NULL
| C           | 2021-01-01 | ramen        | 12    | N      | NULL
| C           | 2021-01-07 | ramen        | 12    | N      | NULL


***
