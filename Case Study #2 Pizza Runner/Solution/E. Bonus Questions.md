# Case Study #2: Bonus Questions from Pizza Runner Case Study

## Solution

### If Danny wants to expand his range of pizzas - how would this impact the existing data design? Write an INSERT statement to demonstrate what would happen if a new Supreme pizza with all the toppings was added to the Pizza Runner menu?

````sql
INSERT INTO
	pizza_names (pizza_id, pizza_name)
VALUES
	(3, "Supreme");
INSERT INTO
	pizza_recipes (pizza_id, toppings)
VALUES
	(3, "1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12");
````
The "pizza_names" table would be as follows:

<img width="208" alt="pizza_runner_QE" src="https://user-images.githubusercontent.com/84310475/191892500-99bee1b2-4a88-4dbb-aa2a-8cdc12c02af9.png">

The "pizza_recipes" table would be as follows:

<img width="348" alt="pizza_runner_QE2" src="https://user-images.githubusercontent.com/84310475/191892591-613dd781-1944-4013-99b9-1f8b3c7b631b.png">

***
