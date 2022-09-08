# Case Study #2: Runner and Customer Experience from Pizza Runner Case Study

## Solution

### Q1. How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)
- 6 days were added to the registration date for the week to start on 2021-01-01. Otherwise, it would count the 1-week period of registraion, starting from Sunday by default.
```sql
SELECT WEEK(registration_date + INTERVAL 6 DAY) registration_week, COUNT(runner_id) runner_registrated
FROM runners
GROUP BY registration_week;
````
| registration_week | runners_registered |
|-------------------|--------------------|
| 1 | 2 |
| 2 | 1 |
| 3 | 1 |
- The number of runners signing up for the delivery for each week was 2, 1 and 1 respectively.

### Q2. What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pick up the order?
````sql
SELECT r.runner_id, round(AVG(TIMESTAMPDIFF(minute, c.order_time, r.pickup_time)),0) avg_arrival_time
FROM runner_orders1 r
JOIN customer_orders1 c
	ON c.order_id = r.order_id
WHERE r.distance != ' '
GROUP BY r.runner_id;
````
| runner_id | avg_arrival_time |
|-----------|------------------|
| 1 | 15 |
| 2 | 23 |
| 3 | 20 |
- The average arrival time for the runners to pick up the order at Pizza Runner HQ was 15, 23 and 20 minutes respectively.

### Q3. Is there any relationship between the number of pizzas and how long the order takes to prepare?
```sql
WITH cte_order_prepared AS(
	SELECT c.order_id, COUNT(c.order_id) pizza_orders, c.order_time, r.pickup_time, (TIMESTAMPDIFF(minute, c.order_time, r.pickup_time)) preparation_time
	FROM runner_orders1 r
	JOIN customer_orders1 c
		ON c.order_id = r.order_id
	WHERE r.distance != 0
	GROUP BY c.order_id, c.order_time, r.pickup_time)
SELECT pizza_orders, ROUND(AVG(preparation_time),0) avg_preparation_time
FROM cte_order_prepared
GROUP BY pizza_orders;
````
| pizza_orders | avg_preparation_time |
|--------------|----------------------|
| 1 | 12 |
| 2 | 18 |
| 3 | 29 |
- The average time it took to prepare a single pizza is around 12 minutes.
- As for 2-pizza order, it would take 18 minutes, and for 3 pizzas: 29 minutes. The more pizzas ordered, the less average time preparing the order, the more efficient.

### Q4. What was the average distance traveled for each customer?
```sql
SELECT c.customer_id, ROUND(AVG(r.distance),1) as avg_distance
FROM runner_orders1 r
JOIN customer_orders1 c
	ON r.order_id = c.order_id
WHERE r.distance != ' '
GROUP BY c.customer_id;
````
| customer_id | avg_distance |
|-------------|--------------|
| 101 | 20 |
| 102 | 16.7 |
| 103 | 23.4 |
| 104 | 10 |
| 105 | 25 |
- The shortest average distance travelled is to customer 104 and the furthest: to customer 105.

### Q5. What was the difference between the longest and shortest delivery times for all orders?
````sql
SELECT max(duration) - min(duration) diff_delivery_time
FROM runner_orders1
WHERE distance != ' ';
````
| diff_delivery_time |
|--------------------|
| 30 |

- The difference between the longest and shortest delivery times for the orders is 30 minutes.

### Q6. What was the average speed for each runner for each delivery and do you notice any trend for these values?
````sql
SELECT runner_id, order_id, distance, ROUND((distance/ duration* 60),1) speed_kmh
FROM runner_orders1
WHERE distance != ' '
GROUP BY runner_id, order_id, distance, speed_kmh
ORDER BY runner_id;
````
| runner_id | order_id | distance | speed_kmh |
|-----------|----------|----------|-----------|
| 1 | 1 | 20 | 37.5 |
| 1 | 2 | 20 | 44.4 |
| 1 | 3 | 13.4 | 40.2 |
| 1 | 10 | 10 | 60 |
| 2 | 4 | 23.4| 35.1 |
| 2 | 7 | 25 | 60 |
| 2 | 8 | 23.4 | 93.6 |
| 3 | 5 | 10 | 40 |
- Runner 1's average speed ranges from 37.5 to 60 km per hour.
- For runner 2, 35.1 to 93.6 kmph, and for runner 3: 40 kmph.
- Though it also depends on the time of the day and traffic, 
- Runner 3 took 40kmh for the same distance of 10 km for which it only took 20 kmh for runner 3. So further investigation is needed to address the issue to find out if the runner 3 took more time on purpose.

### Q7. What is the successful delivery percentage for each runner?
````sql
WITH cte_success_rate AS
(SELECT runner_id,
	SUM(CASE
	    WHEN distance != 0 THEN 1
            ELSE 0
            END) success_rate,
	COUNT(order_id) order_count
FROM runner_orders1
GROUP BY runner_id)

SELECT runner_id, ROUND(((success_rate/order_count) * 100),2) percentage
FROM cte_success_rate
GROUP BY runner_id;
````
| runner_id | percentage |
|-----------|------------|
| 1 | 100.00 |
| 2 | 75.00 |
| 3 | 50.00 |
- Runner 1 has 100 % of successful delivery rate with runner 2 and 3 having 75 % and 50 % respectively.









