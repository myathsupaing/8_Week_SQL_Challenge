# Data Cleaning

## SQL functions:
- DROP TABLE,
- CREATE TABLE AS,
- UPDATE SET,
- CASE WHEN,
- OR,
- REPLACE,
- ALTER TABLE, and
- ALTER COLUMN.
 In 'customer_orders' table below, there are blank (' ') and "null" values in 'exclusions' and 'extras' columns.

## TABLE: customer_orders
 
 To clean the 'customer_orders' table,
- a new table called 'customer_orders1' was created in order to avoid any loss of the original data, and
- null values were removed, using CASE WHEN () function.

<img width="1063" alt="image" src="https://user-images.githubusercontent.com/81607668/129472388-86e60221-7107-4751-983f-4ab9d9ce75f0.png">

Tasks:
- exclusion - remove nulls and replace with ' '
- extras - remove nulls and replace with ' '

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
<img width="1058" alt="image" src="https://user-images.githubusercontent.com/81607668/129472551-fe3d90a0-1e8b-4f32-a2a7-2ecd3ac469ef.png">

## TABLE: Runner_orders
 To clean the 'runner_orders' table,
- a new table called 'runner_orders1' was created in order to avoid any loss of the original data,
- null values were removed, using CASE WHEN () function, and
- units were removed, using REPLACT () function.

<img width="1063" alt="image" src="https://user-images.githubusercontent.com/81607668/129472388-86e60221-7107-4751-983f-4ab9d9ce75f0.png">
Tasks:
- pickuptime - remove nulls and replace with ' '
- distance - remove nulls and replace with ' '
- duration - remove nulls and replace with ' '
- duration - remove nulls and replace with ' '
- distance - trim 'km' with ' '
- duration - trim 'minutes', 'min', 'minute' with ' '

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
	  	WHEN pickup_time IS 'null' THEN ' '
	  	ELSE pickup_time
	  	END,
        
distance =  CASE
	  	   WHEN distance IS 'null' THEN ' '
	  	   ELSE distance
	  	   END,

duration =  CASE
	  	   WHEN duration IS 'null' THEN ' '
	  	   ELSE duration
	  	   END,
          
cancellation =  CASE
	  	   WHEN cancellation IS NULL OR 'null' THEN ' '
	  	   ELSE cancellation
	  	   END;
````

### Trimming data		   
````sql
UPDATE runner_orders1
SET
distance = replace(distance,'km',''),
duration = REPLACE(REPLACE(replace(duration,'minutes',''),'mins', ''),'minute','')
````

## TABLE: runner_orders
Tasks:
- pickup_time - DATETIME format
- distance - FLOAT format
- cancellation - INT format

````sql
ALTER TABLE runner_orders1
MODIFY COLUMN pickup_time DATETIME,
MODIFY COLUMN distance FLOAT,
MODIFY COLUMN duration INT;
````

The cleaned "runner_orders1" table is as below:
<img width="915" alt="image" src="https://user-images.githubusercontent.com/81607668/129472778-6403381d-6e30-4884-a011-737b1eff7379.png">
