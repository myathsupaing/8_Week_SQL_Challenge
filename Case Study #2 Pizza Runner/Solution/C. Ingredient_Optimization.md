# Case Study #2: Ingredient Optimization from Pizza Runner Case Study

## Solution

### Q1. What are the standard ingredients for each pizza?
- Firstly, I created a new table named 'pizza_recipes1',
- concatenated the values from the 'toppings' column of the 'pizza_recipes' table with those from the 'numbers' table into a single row, using the function SUBSTRING_INDEX.
- Then, I joined the new table created with the 'pizza_toppings' and the 'pizza_names' tables to retrieve the topping names and the pizza names.
````sql
CREATE TABLE pizza_recipes1
(SELECT
  p.pizza_id,
  SUBSTRING_INDEX(SUBSTRING_INDEX(p.toppings, ',', numbers.n), ',', -1) toppings
FROM
  (SELECT 1 n UNION ALL
   SELECT 2 UNION ALL
   SELECT 3 UNION ALL
   SELECT 4 UNION ALL
   SELECT 5 UNION ALL
   SELECT 6 UNION ALL
   SELECT 7 UNION ALL
   SELECT 8 UNION ALL
   SELECT 9) numbers
   INNER JOIN pizza_recipes p
  	ON CHAR_LENGTH(p.toppings)
     		-CHAR_LENGTH(REPLACE(p.toppings, ',', ''))>=numbers.n-1
ORDER BY p.pizza_id, n)
````
````sql
WITH cte_toppings AS (
	SELECT pn.pizza_name,pr.pizza_id, pt.topping_name
	FROM pizza_recipes1 pr
	JOIN pizza_toppings pt
		ON pr.toppings = pt.topping_id
	JOIN pizza_names pn
		ON pn.pizza_id = pr.pizza_id
	ORDER BY pn.pizza_name, pr.pizza_id)
SELECT pizza_name, group_concat(topping_name) std_toppings
FROM cte_toppings
GROUP BY pizza_name;
````
- The standard ingredients of each pizza type are as follows:

| pizza_name | std_toppings |
|------------|--------------|
| Meatlovers | Bacon,BBQ Sauce,Beef,Cheese,Chicken,Mushroom,Pepperoni,Salami |
| Vegetarian | Cheese,Mushrooms,Onions,Peppers,Tomatoes,Tomato Sauce |

### Q2. What was the most commonly added extra?
- Just like the previous question, the sames process was gone through.
````sql
CREATE TABLE extras
(SELECT
	c.order_id,
	SUBSTRING_INDEX(SUBSTRING_INDEX(c.extras, ',', numbers.n), ',', -1) extras
FROM
  (SELECT 1 n UNION ALL
   SELECT 2 UNION ALL
   SELECT 3 UNION ALL
   SELECT 4 UNION ALL
   SELECT 5 UNION ALL
   SELECT 6 UNION ALL
   SELECT 7 UNION ALL
   SELECT 8 UNION ALL
   SELECT 9 UNION ALL
   SELECT 10 UNION ALL
   SELECT 11 UNION ALL
   SELECT 12) numbers
   JOIN customer_orders1 c
	ON CHAR_LENGTH(c.extras)
     		-CHAR_LENGTH(REPLACE(c.extras, ',', ''))>=numbers.n-1
ORDER BY c.order_id, n);
````
````sql
SELECT  pt.topping_name, COUNT(e.extras) occurence
FROM pizza_toppings pt
JOIN extras e
	ON e.extras = pt.topping_id
GROUP BY pt.topping_name
ORDER BY occurence DESC;
````
| topping_name | occurence |
|--------------|-----------|
| Bacon | 4 |
| Chicken | 1 |
| Cheese | 1 |

- Bacon was the most commonly added extra.

### Q3. What was the most common exclusion?
- Using the same procedure just like the previous two questions:
````sql
CREATE TABLE exclusions
(SELECT
	c.order_id,
	SUBSTRING_INDEX(SUBSTRING_INDEX(c.exclusions, ',', numbers.n), ',', -1) exclusions
FROM
  (SELECT 1 n UNION ALL
   SELECT 2 UNION ALL
   SELECT 3 UNION ALL
   SELECT 4 UNION ALL
   SELECT 5 UNION ALL
   SELECT 6 UNION ALL
   SELECT 7 UNION ALL
   SELECT 8 UNION ALL
   SELECT 9 UNION ALL
   SELECT 10 UNION ALL
   SELECT 11 UNION ALL
   SELECT 12) numbers
   JOIN customer_orders1 c
		ON CHAR_LENGTH(c.exclusions)
     -CHAR_LENGTH(REPLACE(c.exclusions, ',', ''))>=numbers.n-1
ORDER BY c.order_id, n);
````

````sql
SELECT  pt.topping_name, COUNT(e.exclusions) occurence
FROM pizza_toppings pt
JOIN exclusions e
	ON e.exclusions = pt.topping_id
GROUP BY pt.topping_name
ORDER BY occurence DESC;
````
| topping_name | occurence |
|--------------|-----------|
| Cheese | 4 |
| BBQ Sauce | 1 |
| Mushrooms | 1 |

- Cheese was the most common exclusion.
