# Case Study #3: Foodie Fi Case Study

## D. Outside The Box Questions

The following are open ended questions which might be asked during a technical interview for this case study - there are no right or wrong answers, but answers that make sense from both a technical and a business perspective make an amazing impression!

## Solution

### 1. How would you calculate the rate of growth for Foodie-Fi?

````sql
WITH months AS (
SELECT
	plan_id,
	MONTH(start_date) AS months,
	YEAR(start_date) AS years,
	COUNT(customer_id) AS current_customers
FROM subscriptions AS s
GROUP BY
	plan_id,
	months,
	years)

SELECT
	months,
	current_customers,
	LAG(current_customers, 1) OVER(ORDER BY months) AS previous_customers,
	100 * (COUNT(customer_id) OVER(ORDER BY months) - LAG(COUNT(customer_id), 1) OVER(ORDER BY months)) /
		LAG(COUNT(customer_id), 1) OVER(ORDER BY months) AS growth_rate
FROM subscriptions AS s
	JOIN plans AS p
	ON s.plan_id = p.plan_id
	JOIN months AS m
	ON s.plan_id = m.plan_id
WHERE
	s.plan_id != 0
	AND s.plan_id != 4
GROUP BY
	months,
	current_customers
ORDER BY
	months;
WITH CTE AS (
	SELECT
		MONTH(start_date) AS months,
		YEAR(start_date) AS years,
		COUNT(customer_id) AS current_customers
	FROM subscriptions AS s
    	WHERE plan_id != 0
		AND plan_id != 4
	GROUP BY
		years,
		months
	ORDER BY
		years,
        	months)
SELECT
	years,
	months,
	current_customers,
	LAG(current_customers, 1) OVER(ORDER BY years, months) AS previous_count,
	100 * (current_customers - LAG(current_customers, 1) OVER(ORDER BY years, months)) /
		LAG(current_customers, 1) OVER(ORDER BY years, months) AS percent
FROM CTE
ORDER BY
	years,
    	months;
````

<img width="407" alt="foodie_fi_q4" src="https://user-images.githubusercontent.com/84310475/191932632-ff7d3282-798e-46c1-8c99-c9a428b76d50.png">

### 2. What key metrics would you recommend Foodie-Fi management to track over time to assess performance of their overall business?
To analyze if the firm is growing or shrinking
- Revenue growth (annually, quarterly & monthly)

To analyze which subscription plan brings more revenue to the firm
- Average revenue per customer for each subscription

To analyze which plan generates more profits (since more revenues isn't always equal to more profits to the firm that some incurs more costs to the firm, leaving with less profits)
- Profit margin by plans

To find out if the current marketing campaign works well
- Customer acquisition rate (i.e. number of new app downloads)

Just as acquiring a new customer can cost five times more than retaining an existing customer, we also need to analyze the following metrics.
- Customer retention rate
- Churn rate (trial to churn & trial to paying plan to churn) (i.e. number of uninstalls)
- Number of active customers by plans (daily & monthly)
- Free trial conversion rate

### 3. What are some key customer journeys or experiences that you would analyse further to improve customer retention?
- User interface
- Market segmentation
- App crashes rate
- Engagement (daily & monthly active users, average session lengths and intervals)
- Reachability percentage (opt-in rate and click-through rate) (i.e. push notifications)

### 4. If the Foodie-Fi team were to create an exit survey shown to customers who wish to cancel their subscription, what questions would you include in the survey?
1. Why do you cancel the subscription?
-  I don’t understand how to use your product
-  It’s too expensive
-  I found another product that I like better
-  I don’t use it enough
-  Some features I need are missing
-  Limited storage space
-  Your app crashes too much
-  Too much advertising
2. How feature would you have wanted to add or enhance?
-  Please explain.......
3. What feature do you think we do well? 
- User interface
- User manual instructions
- Customer support
- Storage space
- Targeted push notification
- Others (Please explain......)

### 5. What business levers could the Foodie-Fi team use to reduce the customer churn rate? How would you validate the effectiveness of your ideas?
Features to be enhanced or added:
- Impressive onboarding and user-friendly UX
- Push notifications (offering limited time coupons)
- In-app user support (FAQs)
- In-app groups (to create a society of similar interests on the platform)
- More tailored experience
- Customer feedback loop
- Exit interview

For trial users to be converted into paying customers, perceived value must be higher than perceived costs.
- Explaining benefits of paid plans
- Unlock paid features for a limited time

Win-back strategy
- Sending offers to churned customers or inactive users
- Notifying new features

***
