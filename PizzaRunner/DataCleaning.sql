--SQL functions:
- DROP TABLE,
- CREATE TABLE AS,
- UPDATE SET,
- CASE WHEN,
- OR,
- REPLACE,
- ALTER TABLE, and
- ALTER COLUMN.

--TABLE: customer_orders
--tasks:
--exclusion - remove nulls and replace with ' '
--extras - remove nulls and replace with ' '

-- Copying data to new table
DROP TABLE if exists customer_orders1;
CREATE TABLE customer_orders1 AS
SELECT *
FROM customer_orders;

-- Cleaning data
UPDATE customer_orders1
SET
exclusions = CASE 
		WHEN exclusions IS 'null' THEN ' '
		else exclusions
		end,
extras = CASE
	     WHEN extras IS NULL or 'null' THEN ' '
	     else extras
	     end;

--TABLE: runner_orders
--tasks:
--pickuptime - remove nulls and replace with ' '
--distance - remove nulls and replace with ' '
--duration - remove nulls and replace with ' '
--duration - remove nulls and replace with ' '
--distance - trim 'km' with ' '
--duration - trim 'minutes', 'min', 'minute' with ' '

--copying data to new table
CREATE TABLE runner_orders1 AS
SELECT *
FROM runner_orders;

-- cleaning data
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
		   
--trimming data		   
UPDATE runner_orders1
SET
distance = replace(distance,'km',''),
duration = REPLACE(REPLACE(replace(duration,'minutes',''),'mins', ''),'minute','')

--TABLE: runner_orders
--tasks:
--pickup_time - DATETIME format
--distance - FLOAT format
--cancellation - INT format

ALTER TABLE runner_orders1
ALTER COLUMN pickup_time DATETIME,
ALTER COLUMN distance FLOAT,
ALTER COLUMN duration INT;
