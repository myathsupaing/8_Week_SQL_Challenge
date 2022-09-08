# Case Study #2: Pizza Metrics from Pizza Runner Case Study


## Solution

### Q1. How many pizzas were ordered?

````sql
SELECT count(pizza_id) pizza_orders 
FROM customer_orders1;
````

|  pizza_orders  |
| -------------- |
| 14             |

- 14 pizzas were ordered in total.

### Q2. How many unique customer orders were made?
````sql
SELECT COUNT(DISTINCT order_id) total_orders
FROM customer_orders1;
````

|   total_orders |
| -------------- |
| 10             |

- 10 unique customer orders were placed in total.

### Q3. How many successful orders were delivered by each runner?
````sql
SELECT runner_id,
       count(order_id) orders_delivered
FROM runner_orders1
WHERE distance != ' '
GROUP BY runner_id;
````

| runner_id | orders_delivered |
|-----------|------------------|
| 1         | 4                |
| 2         | 3                |
| 3         | 1                |

- Runner 1 got the most deliveries.
- As for runner 2, it is 3 successful orders, and runner 3, 1 order.

### Q4. How many of each type of pizza was delivered?
````sql
SELECT p.pizza_name,
       COUNT(c.pizza_id) orders_delivered
FROM customer_orders1 c
JOIN runner_orders1 r
ON c.order_id = r.order_id
JOIN pizza_names p
ON p.pizza_id = c.pizza_id
WHERE r.distance != ' '
GROUP BY  p.pizza_name;
````

| pizza_names | orders_delivered |
|-------------|------------------|
| Meatlovers  | 9                |
| Vegetarian  | 3                |

- Meat pizzas were preferred to vegetarian with the ratio of 9:3.

### Q5. How many Vegetarian and Meatlovers were ordered by each customer?
````sql
SELECT c.customer_id,
       p.pizza_name,
       COUNT(p.pizza_id) pizza_orders
FROM customer_orders1 c
JOIN pizza_names p
  ON c.pizza_id = p.pizza_id
GROUP BY c.customer_id, p.pizza_name
ORDER BY c.customer_id;
````

| customer_id | pizza_names | orders_delivered |
|-------------|-------------|------------------|
| 101         | Meatlovers  | 2                |
| 101         | Vegetarian  | 1                |
| 102         | Meatlovers  | 2                |
| 102         | Vegetarian  | 1                |
| 103         | Meatlovers  | 3                |
| 103         | Vegetarian  | 1                |
| 104         | Meatlovers  | 3                |
| 105         | Vegetarian  | 1                |

- Meat pizzas were preferred by every customer, except for customer 105.

### Q6. What was the maximum number of pizzas delivered in a single order?
````sql
SELECT c.order_id, 
       COUNT(c.pizza_id) pizza_per_order
FROM customer_orders1 AS c
JOIN runner_orders1 AS r
  ON c.order_id = r.order_id
WHERE r.distance != ' '
GROUP BY c.order_id
ORDER BY pizza_per_order DESC
LIMIT 1;
````

| order_id | pizza_per_order |
|----------|-----------------|
| 4        | 3               |

- Maximum number of pizza delivered in a single order is 3 pizzas.
 
### Q7. For each customer, how many delivered pizzas had at least 1 change, and how many had no changes?
````sql
SELECT 
  c.customer_id,
  SUM(
    CASE WHEN (c.exclusions != ' ' AND c.exclusions != 0)OR (c.extras != ' ' AND c.extras != 0) THEN 1
    ELSE 0
    END) AS at_least_1_change,
  SUM(
    CASE WHEN (c.exclusions = ' ' OR c.exclusions = 0) AND (c.extras = ' ' OR c.extras = 0)THEN 1 
    ELSE 0
    END) AS no_change
FROM customer_orders1 c
JOIN runner_orders1 r
  ON c.order_id = r.order_id
WHERE r.distance != ' ' OR r.distance != 0
GROUP BY c.customer_id
ORDER BY c.customer_id;
````

| customer_id | at_least_1_change | no_change |
|-------------|-------------|------------------|
| 101         | 0           | 2                |
| 102         | 0           | 3                |
| 103         | 3           | 0                |
| 104         | 2           | 1                |
| 105         | 1           | 0                |

- Customer 101 and 102 likes the original recipe just as it is.
- Customer 103, 104 and 105 like to have some changes on their pizzas.

### Q8. How many pizzas were delivered that had both exclusions and extras?
````sql
SELECT  
  SUM(
    CASE WHEN (c.exclusions IS NOT NULL AND c.exclusions != 0) AND (c.extras IS NOT NULL AND c.extras != 0) THEN 1
    ELSE 0
    END) AS both_exclusion_extras
FROM customer_orders1 AS c
JOIN runner_orders1 AS r
  ON c.order_id = r.order_id
WHERE r.distance != ' '
  AND exclusions <> ' ' 
  AND extras <> ' ';
  ````
  
| both_exclusion_extras |
|-----------------------|
| 1                     |

  
  - Only 1 pizza was delivered that had both extra and exclusion topping.
  
### Q9. What was the total volume of pizzas ordered for each hour of the day?
````sql
SELECT
  HOUR(order_time) hour_of_day,
  COUNT(order_id) AS pizza_count
FROM customer_orders1
GROUP BY hour_of_day
ORDER BY hour_of_day;
````

| hour_of_day | pizza_count |
|-------------|-------------|
| 11          | 1           |
| 13          | 3           |
| 18          | 3           |
| 19          | 1           |
| 21          | 3           |
| 23          | 3           |

- Highest volume of pizzas ordered is 3 at 1:00 pm, at 6:00 pm, at 9:00 pm, and at 11:00 pm.
- Lowest volume of pizzas ordered is 1 at 11:00 am and at 7:00 pm.

#### Q10. What was the volume of orders for each day of the week?
````sql
SELECT DAYNAME(order_time) daily_data, COUNT(order_id) pizza_orders
FROM customer_orders1
GROUP BY daily_data;
````

| daily_data | pizza_orders |
|------------|--------------|
| Wednesday  | 5            |
| Thursday   | 3            |
| Saturday   | 5            |
| Friday     | 1            |

- Wednesdays & Saturdays are the busiest days of the week with the total orders of 5 pizzas
