USE stolen_vehicles_db;

/* OVERALL FIRST OBJECTIVE:
Identify when vehicles are likely to be stolen*/

-- Q1.Find the number of vehicles stolen each year
SELECT
	YEAR(date_stolen),
    COUNT(vehicle_id) AS num_of_vechicle_stolen
FROM stolen_vehicles
GROUP BY YEAR(date_stolen);

-- Q2.Find the number of vehicles stolen each month
SELECT
	COUNT(vehicle_id) AS num_of_vechicle_stolen,
	MONTH(date_stolen) AS month_of_the_year,
    YEAR(date_stolen)
FROM stolen_vehicles
GROUP BY MONTH(date_stolen), YEAR(date_stolen)
ORDER BY YEAR(date_stolen),month_of_the_year;

-- Q3.Find the number of vehicles stolen each day of the week
SELECT 
	DAYOFWEEK(date_stolen) AS day_of_week,
    COUNT(vehicle_id) AS num_of_vechicle_stolen
FROM stolen_vehicles
GROUP BY day_of_week
ORDER BY day_of_week;

-- Q4.Replace the numeric day of week values with the full name of each day of the week

-- OPTION 1 using DATE_FORMAT
SELECT 
	DATE_FORMAT(date_stolen,'%W') AS day_of_week, -- directly extract yyyy-mm-dd to 1-7 day of the week
    COUNT(vehicle_id) AS num_of_vechicles_stolen
FROM stolen_vehicles
GROUP BY day_of_week
ORDER BY FIELD(day_of_week, 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'); -- manually change order of the weekdays, if not specified then random order

-- OPTION 2 using CASE WHEN
SELECT 
	DAYOFWEEK(date_stolen) AS dow,
    CASE WHEN DAYOFWEEK(date_stolen) = 1 THEN 'SUNDAY'
		 WHEN DAYOFWEEK(date_stolen) = 2 THEN 'MONDAY'
         WHEN DAYOFWEEK(date_stolen) = 3 THEN 'TUESDAY'
		 WHEN DAYOFWEEK(date_stolen) = 4 THEN 'WEDNSDAY'
         WHEN DAYOFWEEK(date_stolen) = 5 THEN 'THURSDAY'
         WHEN DAYOFWEEK(date_stolen) = 6 THEN 'FRIDAY'
         ELSE 'SATURDAY' 
         END AS day_of_week,
    COUNT(vehicle_id) AS num_of_vechicles_stolen
FROM stolen_vehicles
GROUP BY dow, day_of_week
ORDER BY dow;

-- Q5. Create a bar chart in Excel that shows the number of vehicles stolen on each day of the week


/* OVERALL SECOND OBJECTIVE:
Identify which vehicles are likely to be stolen using the stolen_vechicles table*/

-- 1. Find the vehicle types that are most often and least often stolen
SELECT 
	stolen_vehicles.vehicle_type,
    COUNT(vehicle_id) AS num_of_times_stolen
FROM stolen_vehicles
GROUP BY stolen_vehicles.vehicle_type
ORDER BY num_of_times_stolen;

-- Q2. For each vehicle type, find the average age of the cars that are stolen
SELECT
	vehicle_type,
	AVG(YEAR(date_stolen) - model_year) AS avg_age
FROM stolen_vehicles
GROUP BY vehicle_type
ORDER BY avg_age DESC;

-- Q3. For each vehicle type, find the percent of vehicles stolen that are luxury versus standard
SELECT
	stolen_vehicles.vehicle_type,
    CASE
		WHEN make_details.make_type = 'luxury' THEN 1
        ELSE 0 
	END AS is_luxury
FROM stolen_vehicles
	LEFT JOIN make_details
     ON stolen_vehicles.make_id = make_details.make_id
GROUP BY 
		stolen_vehicles.vehicle_type,
		make_details.make_type;
        
-- OPTION 2:
/* 1 join two tables together
2. find the essential fields and put them in SELECT
3. using case statment to find luxury and non luxury vehicles, put in select*/

WITH lux_standard AS
(SELECT vehicle_type, 
	   CASE WHEN make_type = 'Luxury' THEN 1 ELSE 0 END AS luxury,
       1 AS all_cars
FROM stolen_vehicles sv
	LEFT JOIN make_details md
    ON sv.make_id = md.make_id)
    
SELECT vehicle_type, SUM(luxury)/SUM(all_cars) * 100 AS lux
FROM lux_standard
GROUP BY vehicle_type
ORDER BY lux DESC;
    
/* Q4. Create a table where the rows represent the top 10 vehicle types, 
the columns represent the top 7 vehicle colors (plus 1 column for all other colors) and the values are the number of vehicles stolen*/

-- first find the top 7 colors 
SELECT 
	color,
    COUNT(vehicle_id)
FROM stolen_vehicles
GROUP BY color
ORDER BY COUNT(vehicle_id) DESC;

/*
'Silver','1272'
'White','934'
'Black','589'
'Blue','512'
'Red','390'
'Grey','378'
'Green','224'
*/

-- Then make each top 7 colors as a column by using case when statement
SELECT
vehicle_type, 
-- 3rd, add COUNT(vehicle_id) to order th top 10 vehicle type
COUNT(vehicle_id) AS num_of_cars,
SUM(CASE WHEN color = 'Silver' THEN 1 ELSE 0 END) AS Silver,
SUM(CASE WHEN color = 'White' THEN 1 ELSE 0 END) AS White,
SUM(CASE WHEN color = 'Black' THEN 1 ELSE 0 END) AS Black,
SUM(CASE WHEN color = 'Blue' THEN 1 ELSE 0 END) AS Blue,
SUM(CASE WHEN color = 'Red' THEN 1 ELSE 0 END) AS Red,
SUM(CASE WHEN color = 'Grey' THEN 1 ELSE 0 END) AS Grey,
SUM(CASE WHEN color = 'Green' THEN 1 ELSE 0 END) AS Green,
SUM(CASE WHEN color IN ('Gold','Brown','Yellow','Orange','Purple','NULL','Cream','Pink') THEN 1 ELSE 0 END) AS other	
FROM stolen_vehicles
GROUP BY vehicle_type
ORDER BY num_of_cars DESC
LIMIT 10;

/* OVERALL THIRD OBJECTIVE, Identify where vehicles are likely to be stolen */
-- Q1 and Q2. Find the number of vehicles that were stolen in each region, then combine the output with the popultation and density statistics for each region
-- Answer Step 1. join locations and stolen_vehicles table together and temp save it using WITH AS, make sure only select the location id from one table
-- Step 2. select region and the sum of vehicle id as the number of cars to show the result

WITH sv_lo AS 
(SELECT 
	sv.location_id,
    lo.region,
    sv.vehicle_id,
    lo.population,
    lo.density
FROM stolen_vehicles sv
	LEFT JOIN locations lo 
    ON sv.location_id = lo.location_id)
    
SELECT 
region,
population,
density,
COUNT(vehicle_id) AS num_of_cars
FROM sv_lo
GROUP BY 
	region,
	population,
    density
ORDER BY num_of_cars DESC;

-- Q3. Do the types of vehicles stolen in the three most dense regions differ from the three least dense regions?
WITH sv_lo AS 
(SELECT 
	sv.location_id,
    lo.region,
    sv.vehicle_id,
    lo.population,
    lo.density,
    sv.vehicle_type
FROM stolen_vehicles sv
	LEFT JOIN locations lo 
    ON sv.location_id = lo.location_id)
    
SELECT 
region,
population,
density,
COUNT(vehicle_id) AS num_of_stolen_cars
FROM sv_lo
GROUP BY 
	region,
	population,
    density
ORDER BY density DESC;

/* 
1. MOST DENSITY Stolen Vehicle types:
1. Trailer 2. Boat Trailer 3. Roadbike
2. LEAST DENSITY stolen Veicle types:
1. Caravan 2. Moped 3. Roadbike
3. Most densily populated area: Auckland
4. Number of cars stolen is associated with population size, not density
*/
