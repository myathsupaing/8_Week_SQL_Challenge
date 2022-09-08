# Case Study #2: Pricing and Ratings from Pizza Runner Case Study

## Solution

### Q1. If a Meat Lovers pizza costs $12 and Vegetarian costs $10 and there were no charges for changes
### how much money has Pizza Runner made so far if there are no delivery fees?
````sql
SELECT SUM(CASE
    WHEN c.pizza_id = 1 THEN 12
    ELSE 10
    END) revenue
FROM customer_orders1 c
JOIN runner_orders1 r
	ON c.order_id = r.order_id
WHERE r.distance != ' ';
````
| revenue |
|---------|
| 138 |
- Pizza Runner has made $ 138 in total.

### Q2. What if there was an additional $1 charge for any pizza extras?
````sql
SELECT
    SUM(CASE
		WHEN (c.extras != ' ' OR c.extras IS NULL) AND c.pizza_id = 1 THEN 12 + 1
		WHEN (c.extras != ' ' OR c.extras IS NULL) AND c.pizza_id = 2 THEN 10 + 1
		WHEN (c.extras = ' ' OR c.extras IS NOT NULL) AND c.pizza_id = 1 THEN 12
		WHEN (c.extras = ' ' OR c.extras IS NOT NULL) AND c.pizza_id = 2 THEN 10
        ELSE 0
		END) price
FROM customer_orders1 c
JOIN runner_orders1 r
	ON c.order_id = r.order_id
WHERE r.distance != ' ';
````

| price |
|-------|
| 147 |
- With the additional $1 charge for the extra toppings, the price would be $147.

### Q3. The Pizza Runner team now wants to add an additional ratings system that allows customers to rate their runner, how would you design an additional table for this new dataset
### — generate a schema for this new table and insert your own data for ratings for each successful customer order between 1 to 5.
- I created a new table called ratings and put some random values to the 'rating' column.
````sql
create table ratings (
order_id integer,
rating integer);
````
````sql
insert into ratings
(order_id, rating)
values
(1,3),
(2,3),
(3,3),
(4,4),
(5,3),
(6, NULL),
(7,4),
(8,5),
(9, NULL),
(10,3);
````
| order_id | ratings |
|----------|---------|
| 1  | 3 |
| 2  | 3 |
| 3  | 3 |
| 4  | 4 |
| 5  | 3 |
| 6  | NULL |
| 7  | 4 |
| 8  | 5 |
| 9  | NULL |
| 10  | 3 |

### Q4. Using your newly generated table — can you join all of the information together to form a table which has the following information for successful deliveries?
- customer_id
- order_id
- runner_id
- rating
- order_time
- pickup_time
- Time between order and pickup
- Delivery duration
- Average speed
- Total number of pizzas

````sql
SELECT c.customer_id,
	c.order_id,
    r.runner_id,
    rt.rating,
    c.order_time,
	r.pickup_time,
    ROUND(TIMESTAMPDIFF(MINUTE, order_time, pickup_time),0) arrival_time, r.duration, ROUND((r.distance  / r.duration * 60), 1) as speed_kmh, COUNT(c.pizza_id) as num_pizzas
FROM customer_orders1 c
JOIN runner_orders1 r
	ON c.order_id = r.order_id
JOIN ratings rt
	ON rt.order_id = c.order_id
GROUP BY c.customer_id, c.order_id, r.runner_id, rt.rating, c.order_time,
r.pickup_time, arrival_time, r.duration, speed_kmh
ORDER BY c.customer_id;
````
<img width="1063" alt="image" src="https://user-images.githubusercontent.com/84310475/187659720-e1461b81-089e-4ab1-a518-75c091d4132f.png">

### Q5. If a Meat Lovers pizza was $12 and Vegetarian $10 fixed prices with no cost for extras and each runner is paid $0.30 per kilometre traveled
### — how much money does Pizza Runner have left over after these deliveries?
````sql
set @basecost = 138;
select @basecost - (sum(distance)) * 0.3 gross_profit
from runner_orders1;
````
| gross_profit |
|--------------|
| 94.44 |
- Gross profit after paying the deliverymen was $94.44.
