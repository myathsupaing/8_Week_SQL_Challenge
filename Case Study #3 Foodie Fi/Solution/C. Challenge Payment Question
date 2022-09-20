# Case Study #3: Foodie Fi Case Study

## C. Challenge Payment Question

## Solution

The Foodie-Fi team wants you to create a new payments table for the year 2020 that includes amounts paid by each customer in the subscriptions table with the following requirements:

- monthly payments always occur on the same day of month as the original start_date of any monthly paid plan
- upgrades from basic to monthly or pro plans are reduced by the current paid amount in that month and start immediately
- upgrades from pro monthly to pro annual are paid at the end of the current billing period and also starts at the end of the month period
- once a customer churns they will no longer make payments

Firstly, I calculated the end date of each subscription according to the subscription plan. I named the subquery as 2020_subscription.

Next, I created recursive cte to calculate the due date of each monthly plan and named the cte as monthly_plan_cte.

Then, I wrote another cte named payment_cte that references the previous monthly_plan_cte to calculate the amount of each subscription payment and the payment order.

````sql
WITH payment_cte AS (
WITH RECURSIVE monthly_plan_cte AS (
SELECT
  customer_id,
  plan_id,
  plan_name,
  start_date,
  end_date,
  price
FROM
    (SELECT
      s.customer_id,
      s.plan_id,
      p.plan_name,
      s.start_date,
      CASE
        WHEN s.plan_id = 3 THEN s.start_date + INTERVAL 1 YEAR
        WHEN s.plan_id = 4 THEN NULL
        WHEN LEAD(start_date) OVER (
            PARTITION BY customer_id
            ORDER BY start_date) IS NOT NULL
          THEN LEAD(start_date) OVER (
            PARTITION BY customer_id
            ORDER BY start_date)
          ELSE '2020-12-31'
          END AS end_date,
      p.price
    FROM subscriptions  AS s
      JOIN plans AS p
      ON s.plan_id = p.plan_id) as 2020_subscription -- end of subquery
    WHERE start_date + INTERVAL 1 MONTH < end_date
    UNION ALL
    SELECT
      customer_id,
      plan_id,
      plan_name,
      start_date + INTERVAL 1 MONTH,
      end_date,
      price
    FROM monthly_plan_cte
    WHERE start_date + INTERVAL 1 MONTH < end_date
      AND plan_id != 3) -- end of recursive cte

SELECT
  customer_id,
  plan_id,
  plan_name,
  start_date AS payment_date,
  end_date,
  price AS amount
FROM monthly_plan_cte
WHERE start_date < '2021-01-01'
ORDER BY customer_id, plan_id) -- end of payment cte

SELECT
  customer_id,
  p.plan_id,
  p.plan_name,
  payment_date,
  CASE
    WHEN LAG(t.plan_id) OVER (
      PARTITION BY customer_id
      ORDER BY t.plan_id)
      != t.plan_id
    AND DATEDIFF(payment_date, LAG(payment_date) OVER (
        PARTITION BY customer_id
        ORDER BY t.plan_id)) < 30
    THEN amount - LAG(amount) OVER (
        PARTITION BY customer_id
        ORDER BY t.plan_id)
    ELSE amount
  END AS amount, -- calculated monthly payment amount
  RANK() OVER(
    PARTITION BY customer_id
    ORDER BY payment_date) AS payment_order
FROM payment_cte AS t
JOIN plans AS p
ON t.plan_id = p.plan_id;
````
<img width="438" alt="foodie_fi_q3" src="https://user-images.githubusercontent.com/84310475/191227086-45e42366-a6c7-4a8a-9184-e12333d6057c.png">





