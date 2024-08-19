USE restaurant_db;

/*1. View the menu_items table and write a query to find the number of items on the menu*/
SELECT *
FROM menu_items;

-- 1.  View the menu_items table and write a query to find the number of items on the menu
SELECT COUNT(menu_item_id)
FROM menu_items;

-- 2. What are the least and most expensive items on the menu?
SELECT *
FROM menu_items
ORDER BY price;


-- 3. How many Italian dishes are on the menu? What are the least and most expensive Italian dishes on the menu?
SELECT *
FROM menu_items
WHERE category = 'Italian'
ORDER BY price;

-- 4. How many dishes are in each category? What is the average dish price within each category?
SELECT 
	category, 
	COUNT(menu_item_id) AS num_dishes
FROM menu_items
GROUP BY category;

SELECT 
	category, 
	AVG(price) AS avg_price
FROM menu_items
GROUP BY category;

-- 5. View the order_details table. What is the date range of the table?
SELECT MIN(order_date), MAX(order_date)
FROM order_details;

-- 6. How many orders were made within this date range? How many items were ordered within this date range?
SELECT COUNT(DISTINCT(order_id))
FROM order_details;

SELECT COUNT(*)
FROM order_details;

-- 7. Which orders had the most number of items?
SELECT 
	order_id,
	COUNT(item_id) AS num_items
FROM order_details
GROUP BY order_id
ORDER BY COUNT(item_id) DESC;

-- 8. How many orders had more than 12 items? 
SELECT COUNT(*) 
-- counting the num of rows in the table below
FROM 
-- Below is a table itself
	(SELECT 
	order_id,
	COUNT(item_id) AS num_items
	FROM order_details
	GROUP BY order_id
	HAVING num_items > 12) AS num_orders;
    
-- 9. Combine the menu_items and order_details tables into a single table
CREATE TABLE secondjoined_table AS
SELECT 
	order_details.order_details_id,
    order_details.order_id,
    order_details.order_date,
    order_details.order_time,
    order_details.item_id,
    menu_items.item_name,
    menu_items.category,
    menu_items.price
FROM order_details
	LEFT JOIN menu_items
		ON order_details.item_id = menu_items.menu_item_id;

-- 10. What were the least and most ordered items? What categories were they in?
SELECT 
    item_name,
    COUNT(order_details_id) AS times_ordered
FROM joined_table
GROUP BY item_name
ORDER BY COUNT(order_details_id) DESC;

-- Second half of the question, FIRST TRY:
SELECT 
	category,
	COUNT(*)
    FROM (SELECT 
		item_name,
		COUNT(item_id) AS times_ordered
	FROM joined_table
	GROUP BY item_name
	ORDER BY COUNT(item_id) DESC)
    GROUP BY category;

-- CORRECTED:
SELECT 
    category,
    COUNT(*) AS num_items -- Added Alias to the derived table below
FROM (
    SELECT 
        item_name,
        category,  -- Added category here
        COUNT(item_id) AS times_ordered
    FROM joined_table
    GROUP BY item_name, category  -- Grouping by category and item_name
    ORDER BY COUNT(item_id) DESC
) AS subquery  -- Added alias for the subquery
GROUP BY category;

-- 11. What were the top 5 orders that spent the most money?
SELECT 
	order_id,
    SUM(price) AS total_spent
FROM joined_table
GROUP BY order_id
ORDER BY SUM(price) DESC
LIMIT 5;

-- 12. View the details of the highest spend order. Which specific items were purchased?
SELECT 
	order_id,
    item_name,
    price
FROM joined_table
WHERE order_id = 440;

-- 13. View the details of the top 5 highest spend orders and what category each order made 
SELECT order_id,
		category,
		COUNT(item_id) AS num_items
FROM joined_table
WHERE order_id IN (440,2075,1957,330,2675)
GROUP BY 
	order_id,
    category;
    
-- 14. How much was the most expensive order in the dataset?
SELECT 
	order_id,
    SUM(price) AS total_spent
FROM joined_table
GROUP BY order_id
ORDER BY total_spent DESC
LIMIT 1;
