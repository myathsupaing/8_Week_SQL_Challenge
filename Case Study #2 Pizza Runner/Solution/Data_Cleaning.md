# Data Cleaning

 In 'customer_orders' table below, there are blank (' ') and "null" values in 'exclusions' and 'extras' columns.

## TABLE: customer_orders
 
 To clean the 'customer_orders' table,
1. A new table called 'customer_orders1' was created by copying data from the source file.
2. Using CASE WHEN () function, null values were removed and replaced with ' ' in the following columns:
- exclusion
- extras

<img width="1063" alt="image" src="https://user-images.githubusercontent.com/81607668/129472388-86e60221-7107-4751-983f-4ab9d9ce75f0.png">


### Copying data to new table
````sql
DROP TABLE if exists customer_orders1;
CREATE TABLE customer_orders1 AS
SELECT *
FROM customer_orders;
````

### Cleaning data
````sql
UPDATE customer_orders1
SET
exclusions = CASE
		WHEN exclusions = 'null' THEN ' '
		else exclusions
		end,
extras = CASE
	     WHEN extras IS NULL OR extras like 'null' THEN ' '
	     else extras
	     end;
````
After cleaning the data, the 'customer_orders1' table would look like the one below.
<img width="1063" alt="image" src="https://user-images.githubusercontent.com/81607668/129472551-fe3d90a0-1e8b-4f32-a2a7-2ecd3ac469ef.png">

## TABLE: Runner_orders
 To clean the 'runner_orders' table,
1. A new table called 'runner_orders1' was created.
2. Using CASE WHEN () function, null values were removed and replaced with ' ' in the following columns:
- pickuptime
- distance
- duration
- duration
3. Using REPLACE() function, units were removed and replace with ' ' in the following columns:
- distance ( trim 'km' with ' ' )
- duration ( trim 'minutes', 'min', 'minute' with ' ' )

<img width="1063" alt="image" src="https://user-images.githubusercontent.com/81607668/129472388-86e60221-7107-4751-983f-4ab9d9ce75f0.png">

### Copying data to new table
````sql
CREATE TABLE runner_orders1 AS
SELECT *
FROM runner_orders;
````

### Cleaning data
````sql
UPDATE runner_orders1
SET
pickup_time = CASE
	  	 WHEN pickup_time = 'null' THEN ' '
	  	 ELSE pickup_time
	  	 END,
        
distance =  CASE
	       WHEN distance = 'null' THEN ' '
	       ELSE distance
	       END,

duration =  CASE
	       WHEN duration = 'null' THEN ' '
	       ELSE duration
	       END,
          
cancellation =  CASE
	  	   WHEN cancellation IS NULL OR cancellation = 'null' THEN ' '
	  	   ELSE cancellation
	  	   END;
````

### Trimming data		   
````sql
UPDATE runner_orders1
SET
distance = REPLACE(distance,'km',''),
duration = REPLACE(REPLACE(replace(duration,'minutes',''),'mins', ''),'minute','')
````

## TABLE: runner_orders
Changed the data types in the following columns:
- pickup_time ( DATETIME format )
- distance ( FLOAT format )
- cancellation ( INT format )

````sql
ALTER TABLE runner_orders1
MODIFY COLUMN pickup_time DATETIME,
MODIFY COLUMN distance FLOAT,
MODIFY COLUMN duration INT;
````

The cleaned "runner_orders1" table is as below:
<img width="1063" alt="image" src="https://user-images.githubusercontent.com/81607668/129472778-6403381d-6e30-4884-a011-737b1eff7379.png">
