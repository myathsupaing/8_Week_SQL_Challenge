# Case Study #3: Foodie Fi Case Study

## A. Customer Journey

## Solution

Based off the 8 sample customers provided in the sample from the subscriptions table, write a brief description about each customer’s onboarding journey.

Try to keep it as short as possible - you may also want to run some sort of join to make your explanations a bit easier!

````sql
SELECT
  s.customer_id, f.plan_name,  s.start_date
FROM foodie_fi.plans f
JOIN foodie_fi.subscriptions s
  ON f.plan_id = s.plan_id
WHERE s.customer_id IN (1,2,11,13,15,16,18,19);
````

<img width="345" alt="Screen Shot 2022-09-11 at 13 08 26" src="https://user-images.githubusercontent.com/84310475/189515547-b369b2e4-5c6a-4876-93ac-c7ff0be5ec23.png">

Among 8 sample customers, I would like to choose 3 interesting cases: customer 13, 15 and 16.

````sql
SELECT
  s.customer_id, f.plan_name,  s.start_date
FROM foodie_fi.plans f
JOIN foodie_fi.subscriptions s
  ON f.plan_id = s.plan_id
WHERE s.customer_id IN (13,15,16);
````

<img width="342" alt="Screen Shot 2022-09-11 at 12 56 53" src="https://user-images.githubusercontent.com/84310475/189515279-c2593b58-34dc-41c0-89da-b3304576309f.png">

#### Customer 15
Customer 15 started the trial on 2020-12-15 and after the trial ended, he or she subscribed to monthly plan
but after a month, he or she stopped using the service.

We need to look into the case to find out more about his or her dissatisfaction about our service.

#### Customer 13 and 16
As for customer 13 and 16, after the trial ended, they both bought basic montly plan
but after 3 to 4 months of using the service, customer 13 susbcribed to pro monthly plan with customer 16 subscribing to pro annual plan.

We need to find out which service generate more revenues to the company
and how we can encourage our current and potential customers to buy the plan, which is more profitable to the firm, by setting new pricing and promotional strategies.

***
