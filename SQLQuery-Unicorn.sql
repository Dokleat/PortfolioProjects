--1. How many customers do we have in the data?

SELECT COUNT(DISTINCT customer_id) AS total_customer FROM customers

--2. What was the city with the most profit for the company in 2015?

SELECT shipping_city,
			 SUM(order_profits) AS Total_profits
FROM orders
JOIN order_details ON orders.order_id = order_details.order_id
WHERE order_date BETWEEN '2015-01-01' AND '2015-12-31'
GROUP BY shipping_city
ORDER BY Total_profits DESC
LIMIT 1;

--3. In 2015, what was the most profitable city's profit?


--4. How many different cities do we have in the data?

SELECT COUNT(DISTINCT shipping_city) AS total_city FROM orders;

--5. Show the total spent by customers from low to high.

SELECT customer_id,
			 SUM(order_sales) as total_spend
FROM orders
JOIN order_details ON orders.order_id = order_details.order_id
GROUP BY customer_id
ORDER BY total_spend;

--6. What is the most profitable city in the State of Tennessee?

SELECT shipping_city,
			 SUM(order_profits) AS Total_profits
FROM orders
JOIN order_details ON orders.order_id = order_details.order_id
WHERE shipping_state = 'Tennessee'
GROUP BY shipping_city
ORDER BY Total_profits DESC
LIMIT 1;

--7. What’s the average annual profit for that city across all years?

SELECT shipping_city,
			 AVG(order_profits) as avg_annual_profit
FROM orders
JOIN order_details ON orders.order_id = order_details.order_id
WHERE shipping_city = 'Lebanon'
GROUP BY shipping_city
ORDER by avg_annual_profit;

--8. What is the distribution of customer types in the data?

SELECT customer_segment, 
			 COUNT(*) as count
FROM customers
GROUP BY customer_segment;

--9. What’s the most profitable product category on average in Iowa across all years?

WITH ProfitableCategory AS (
  SELECT p.product_category, SUM(od.order_profits) AS total_profits
  FROM orders o
  JOIN order_details od ON o.order_id = od.order_id
  JOIN product p ON od.product_id = p.product_id
  WHERE o.shipping_state = 'Iowa'
  GROUP BY p.product_category
  ORDER BY total_profits DESC
  LIMIT 1
),
YearlyAverage AS (
  SELECT
    p.product_category,
    EXTRACT(YEAR FROM o.order_date) AS order_year,
    AVG(od.order_profits) AS average_profits
  FROM orders o
  JOIN order_details od ON o.order_id = od.order_id
  JOIN product p ON od.product_id = p.product_id
  WHERE p.product_category = (SELECT product_category FROM ProfitableCategory)
    AND o.shipping_state = 'Iowa'
  GROUP BY p.product_category, order_year
)
SELECT *
FROM YearlyAverage
ORDER BY order_year;

--10. What is the most popular product in that category across all states in 2016?

SELECT product_name,
			 SUM(quantity) AS total_quantity
FROM orders
JOIN order_details ON order_details.order_id = orders.order_id
JOIN product ON product.product_id = order_details.product_id
WHERE product_category = 'Furniture'
AND EXTRACT(YEAR FROM order_date) = 2016
GROUP BY product_name
ORDER BY total_quantity DESC
LIMIT 1;

--11. Which customer got the most discount in the data? (in total amount)

SELECT c.customer_id, SUM((order_sales / (1 - order_discount)) - order_sales) AS total_discount
FROM orders o
JOIN order_details od ON o.order_id = od.order_id
JOIN customers c ON o.customer_id = c.customer_id
GROUP BY c.customer_id
ORDER BY total_discount DESC
LIMIT 1;

--12. How widely did monthly profits vary in 2018?

WITH MonthlyProfits AS (
  SELECT
    EXTRACT(MONTH FROM o.order_date) AS order_month,
    SUM(od.order_profits) AS total_profits
  FROM orders o
  JOIN order_details od ON o.order_id = od.order_id
  WHERE EXTRACT(YEAR FROM o.order_date) = 2018
  GROUP BY order_month
),
ProfitDifferences AS (
  SELECT
    order_month,
    total_profits,
    total_profits - LAG(total_profits, 1) OVER (ORDER BY order_month) AS profit_difference
  FROM MonthlyProfits
)

SELECT *
FROM ProfitDifferences
ORDER BY order_month;

--13. Which order was the highest in 2015?

SELECT o.order_id, SUM(od.order_sales) AS total_sales
FROM orders o
JOIN order_details od ON o.order_id = od.order_id
WHERE EXTRACT(YEAR FROM o.order_date) = 2015
GROUP BY o.order_id
ORDER BY total_sales DESC
LIMIT 1;

--14. What was the rank of each city in the East region in 2015 in quantity?

SELECT
  o.shipping_city,
  SUM(od.quantity) AS total_quantity,
  RANK() OVER (ORDER BY SUM(od.quantity) DESC) AS city_rank
FROM orders o
JOIN order_details od ON o.order_id = od.order_id
WHERE EXTRACT(YEAR FROM o.order_date) = 2015 AND o.shipping_region = 'East'
GROUP BY o.shipping_city
ORDER BY total_quantity DESC;

--15. Display customer names for customers who are in the segment ‘Consumer’ or ‘Corporate.’ How many customers are there in total?

SELECT COUNT(DISTINCT customer_id) AS total_customers
FROM customers
WHERE customer_segment = 'Consumer' OR customer_segment = 'Corporate';

--16. Calculate the difference between the largest and smallest order quantities for product id ‘100.’

SELECT MAX(quantity) - MIN(quantity) AS quantity_difference
FROM order_details
WHERE product_id = '100';

--17. Calculate the percent of products that are within the category ‘Furniture.’

SELECT
  (SELECT COUNT(*) FROM product WHERE product_category = 'Furniture')::float /
  COUNT(*) * 100 AS percentage_furniture
FROM product;

--18. Display the number of product manufacturers with more than 1 product in the product table.

SELECT product_manufacturer, COUNT(*) AS total_products
FROM product
GROUP BY product_manufacturer
HAVING COUNT(*) > 2;

--19. Show the product_subcategory and the total number of products in the subcategory.
--Show the order from *most* to *least* products and then by product_subcategory name ascending.

SELECT product_subcategory, COUNT(*) AS total_products
FROM product
GROUP BY product_subcategory
ORDER BY total_products DESC, product_subcategory ASC;

--20. Show the product_id(s), the sum of quantities, where the total sum of its product quantities is greater than or equal to 100

SELECT product_id, SUM(quantity) AS total_quantity
FROM order_details
WHERE quantity >= 100
GROUP BY product_id;