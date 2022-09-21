# Case Study #3: Foodie Fi Case Study

## C. Challenge Payment Question

The Foodie-Fi team wants you to create a new payments table for the year 2020 that includes amounts paid by each customer in the subscriptions table with the following requirements:

- monthly payments always occur on the same day of month as the original start_date of any monthly paid plan
- upgrades from basic to monthly or pro plans are reduced by the current paid amount in that month and start immediately
- upgrades from pro monthly to pro annual are paid at the end of the current billing period and also starts at the end of the month period
- once a customer churns they will no longer make payments

## Solution


Firstly, I calculated the end date of each subscription according to the subscription plan. Since the payment table is for 2020, the end dates of all plans have to be '2020-12-31' even though the customer continues to use the service for the next year. I named the subquery as 2020_subscription.

Next, I created recursive cte named monthly_plan_cte to calculate the due date of each monthly plan payment.

Then, I wrote another cte named payment_cte that references the previous monthly_plan_cte to calculate the amount of each subscription payment and the payment order. The payment for the plan upgrades before the current plan hasn't ended for the month subscribed, would be deducted by the paid amount for that month.

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
      ON s.plan_id = p.plan_id) AS 2020_subscription -- end of subquery (to calculate the end date of each plan in 2020)
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
      AND plan_id != 3) -- end of recursive cte (to calculate the monthly payment date of each monthly plan)

SELECT
  customer_id,
  plan_id,
  plan_name,
  start_date AS payment_date,
  end_date,
  price AS amount
FROM monthly_plan_cte
WHERE start_date < '2021-01-01'
ORDER BY customer_id, plan_id) -- end of payment cte (to calculate each monthly bill)

SELECT
  customer_id,
  p.plan_id,
  p.plan_name,
  payment_date,
  CASE
    WHEN LAG(t.plan_id) OVER (
        PARTITION BY customer_id
        ORDER BY t.plan_id)
        != t.plan_id -- to see if there is any change of subscription
    AND DATEDIFF(payment_date, LAG(payment_date) OVER (
        PARTITION BY customer_id
        ORDER BY t.plan_id)) < 30 -- if the date difference is less than 30 days
    THEN amount - LAG(amount) OVER (
        PARTITION BY customer_id
        ORDER BY t.plan_id) -- then the paid amount would be deducted from the bill of the new plan
    ELSE amount -- otherwise the full amount should be paid for the new subscription
  END AS amount, -- to calculate monthly payment amount
  RANK() OVER(
    PARTITION BY customer_id
    ORDER BY payment_date) AS payment_order -- payment is ordered by the payment date
FROM payment_cte AS t
JOIN plans AS p
ON t.plan_id = p.plan_id;
````
The query returns  4,300 rows and a few rows of its result are as follows:

<img width="438" alt="foodie_fi_q3" src="https://user-images.githubusercontent.com/84310475/191227086-45e42366-a6c7-4a8a-9184-e12333d6057c.png">

***
