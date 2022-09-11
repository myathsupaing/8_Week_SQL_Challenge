# Case Study #3: Foodie Fi Case Study

## B. Data Analysis Questions

## Solution

### 1. How many customers has Foodie-Fi ever had?
````sql
SELECT
  COUNT(DISTINCT customer_id) customers
FROM subscriptions;
````
<img width="154" alt="Screen Shot 2022-09-11 at 01 21 37" src="https://user-images.githubusercontent.com/84310475/189497637-339eade2-b602-496b-bd08-4fc72fa968a8.png">

***Foodie Fi has had 1,000 customers so far.***

### 2. What is the monthly distribution of trial plan start_date values for our dataset - use the start of the month as the group by value
````sql
SELECT
  EXTRACT(MONTH FROM start_date) months,
  MONTHNAME(start_date) month_name,
  COUNT(DISTINCT customer_id) customers
FROM subscriptions
WHERE plan_id = 0
GROUP BY
  months,
  month_name
ORDER BY months;
````

***The number of monthly customers is as follows:***

<img width="301" alt="Screen Shot 2022-09-10 at 23 05 57" src="https://user-images.githubusercontent.com/84310475/189492993-f6ebf585-e577-40d5-838f-8e39ad7ca790.png">
    
### 3. What plan start_date values occur after the year 2020 for our dataset? Show the breakdown by count of events for each plan_name.
````sql
SELECT
  p.plan_id,
  p.plan_name,
  COUNT(p.plan_id) events_2020
FROM subscriptions s
  JOIN plans p
  USING (plan_id)
WHERE s.start_date < '2020-12-31'
GROUP BY
  s.plan_id,
  p.plan_name
ORDER BY s.plan_id;
````

***The number of each plan subscription in 2020 is as follows:***

<img width="251" alt="Screen Shot 2022-09-11 at 01 06 53" src="https://user-images.githubusercontent.com/84310475/189497168-d06604e5-148d-44d1-b085-33e23ce03ccf.png">

### 4. What is the customer count and percentage of customers who have churned rounded to 1 decimal place?
````sql
SELECT
  COUNT(DISTINCT customer_id) churn_ct,
  ROUND(COUNT(customer_id) * 100/ (SELECT COUNT(DISTINCT customer_id) 
        FROM subscriptions),1) churn_rate
FROM subscriptions
WHERE plan_id = 4;
````

<img width="176" alt="Screen Shot 2022-09-10 at 17 48 27" src="https://user-images.githubusercontent.com/84310475/189480861-1fb5ebab-74e4-4820-bc98-db1367a96368.png">

***The number of customers who have churned is 307 with the churn rate being 30.7%.***

### 5. How many customers have churned straight after their initial free trial - what percentage is this rounded to the nearest whole number?
To find the previous plan the customers subscribed to
````sql
WITH prev_plan_cte AS (
  SELECT
    *,
    LAG(plan_id, 1) OVER(PARTITION BY customer_id ORDER BY plan_id) prev_plan
  FROM subscriptions)
SELECT
  COUNT(customer_id) churn_cust,
  ROUND(COUNT(customer_id) * 100 / (SELECT COUNT(DISTINCT customer_id)
        FROM subscriptions),0) churn_perc
FROM prev_plan_cte
WHERE plan_id = 4 and prev_plan = 0; -- previous plan: trial, current plan: churned
````

<img width="176" alt="Screen Shot 2022-09-10 at 17 49 33" src="https://user-images.githubusercontent.com/84310475/189480903-5a4bd1a0-ccae-430c-a4bb-0ac2c28f15ba.png">

***The number of customers who have churned right after free trial is 92 with the churn rate being 9%.***

### 6. What is the number and percentage of customer plans after their initial free trial?
To retriveve the next plan package the customers purchased
````sql
WITH next_plan_cte AS (
	SELECT
		*,
		LEAD(plan_id, 1) OVER(PARTITION BY customer_id ORDER BY plan_id) next_plan
    FROM subscriptions
		JOIN plans
        USING (plan_id)),
cte AS (
	SELECT
		next_plan,
		COUNT(next_plan) conversion,
		ROUND(100 * COUNT(next_plan) / (SELECT COUNT(DISTINCT customer_id)
									FROM subscriptions), 2) conversion_perc
FROM next_plan_cte n
WHERE plan_id = 0
GROUP BY
	next_plan)
SELECT
	next_plan,
    plan_name,
    conversion,
    conversion_perc
FROM cte
	JOIN plans p
    WHERE cte.next_plan = p.plan_id;
````

***The number and the percentage of plan subscriptions after their initial free trial are as follows:***

<img width="348" alt="Screen Shot 2022-09-11 at 00 57 43" src="https://user-images.githubusercontent.com/84310475/189496871-2a21b7e4-9b1d-4d27-9726-b2a9aba0a7ef.png">

### 7. What is the customer count and percentage breakdown of all 5 plan_name values at 2020-12-31?
````sql
WITH latest_plan_cte AS (
  SELECT
    *,
    ROW_NUMBER() OVER(PARTITION BY customer_id
       ORDER BY start_date DESC) latest_plan
  FROM subscriptions
    JOIN plans
    USING (plan_id)
  WHERE start_date <='2020-12-31')
SELECT 
  plan_id,
  plan_name,
  COUNT(customer_id) AS customers,
  ROUND(100 * COUNT(customer_id) / (SELECT COUNT(DISTINCT customer_id)
        FROM subscriptions), 2) percentage
FROM latest_plan_cte
WHERE latest_plan = 1
GROUP BY
  plan_id,
  plan_name
ORDER BY plan_id;
````

***The number of each customer type and their percentage breakdown on 2020-12-31 are as follows:***

<img width="374" alt="Screen Shot 2022-09-10 at 17 50 56" src="https://user-images.githubusercontent.com/84310475/189480970-5c0619ac-6989-4b59-aec8-36ace1ab738d.png">

### 8. How many customers have upgraded to an annual plan in 2020?
````sql
SELECT
  COUNT(distinct customer_id) unique_customers
FROM subscriptions
WHERE start_date < '2020-12-31'
  AND plan_id = 3;
````

<img width="177" alt="Screen Shot 2022-09-10 at 22 52 23" src="https://user-images.githubusercontent.com/84310475/189492444-eca24e38-736c-44dc-ad39-11806bb7373c.png">

***195 customers upgraded to an annual plan in 2020.***

### 9. How many days on average does it take for a customer to an annual plan from the day they join Foodie-Fi?
````sql
WITH next_plan_cte AS (
  SELECT
    *,
    LEAD(plan_id, 1) OVER(PARTITION BY customer_id ORDER BY plan_id) next_plan,
    LEAD(start_date, 1) OVER(PARTITION BY customer_id ORDER BY start_date) next_start_date
  FROM subscriptions)
SELECT
   ROUND(AVG(DATEDIFF(n.next_start_date, s.start_date)),0) AS avg_days_to_upgrade
FROM next_plan_cte n
  JOIN subscriptions s
  USING (customer_id)
WHERE s.plan_id = 0 and n.next_plan = 3;
````

<img width="196" alt="Screen Shot 2022-09-10 at 17 52 29" src="https://user-images.githubusercontent.com/84310475/189481062-57ed3fbd-2dfa-4077-902a-34c14223df39.png">

***It takes 105 days on average for a customer to upgrade to an annual plan from the first day they subscribed.***

### 10. Can you further breakdown this average value into 30 day periods (i.e. 0-30 days, 31-60 days etc)
````sql
WITH next_plan_cte AS (
  SELECT
    *,
    LEAD(plan_id, 1) OVER(PARTITION BY customer_id ORDER BY plan_id) next_plan,
    LEAD(start_date, 1) OVER(PARTITION BY customer_id ORDER BY start_date) next_start_date
  FROM subscriptions),
days AS (
  SELECT
    DATEDIFF(next_start_date, start_date) AS days,
    ROUND(DATEDIFF(next_start_date, start_date) / 30) AS 30_day_period
  FROM next_plan_cte
  WHERE next_plan = 3)
SELECT
  CONCAT((30_day_period * 30) + 1, '-', (30_day_period + 1) * 30, 'days') AS days,
  COUNT(*) AS customers
FROM days
GROUP BY 30_day_period
ORDER BY 30_day_period;
````

***The average number of days it takes for a customer to upgrade to an annual plan in terms of 30-day intervals is as follows:***

<img width="202" alt="Screen Shot 2022-09-10 at 17 53 04" src="https://user-images.githubusercontent.com/84310475/189481079-88bd2b0b-79fa-48c8-861a-9f6ea4404510.png">

### 11. How many customers downgraded from a pro monthly to a basic monthly plan in 2020?
````sql
WITH next_plan_cte AS (
  SELECT
    *,
    LEAD(plan_id, 1) OVER(PARTITION BY customer_id ORDER BY plan_id) next_plan
  FROM subscriptions)
SELECT
  COUNT(*) downgraded
FROM next_plan_cte n
WHERE plan_id = 2
  AND next_plan = 1
  AND start_date <= '2020-12-31';
````

<img width="118" alt="Screen Shot 2022-09-10 at 17 53 38" src="https://user-images.githubusercontent.com/84310475/189481104-8e8fab27-0977-402b-bced-dba285f19abe.png">

***There was no single customer who downgraded from a pro monthly to a basic monthly plan in 2020.***

***
