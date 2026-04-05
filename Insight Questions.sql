1. Customer with most purchases 

SELECT 
	c.customer_id,
	c.company_name,
	COUNT(o.order_id) AS total_purchase
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.company_name
ORDER BY total_purchase DESC;


2.  Average freight charges 

SELECT 
	AVG(freight)
FROM orders;


3. Top country/city by sales 

SELECT 
	c.country,
	c.city,
	SUM(od.unit_price * od.quantity * (1-od.discount)) AS total_sales
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN order_details od ON o.order_id = od.order_id
GROUP BY c.country, c.city
ORDER BY total_sales DESC;


4. Top employees 

SELECT 
	e.employee_id,
	e.employee_name,
	ROUND(SUM(od.unit_price * od.quantity * (1-od.discount)),2) AS total_sales
FROM employees e
JOIN orders o ON e.employee_id = o.employee_id
JOIN order_details od ON o.order_id = od.order_id
GROUP BY e.employee_id, e.employee_name
ORDER BY total_sales DESC;


5. Most sold product/category 

SELECT 
	p.product_id,
	p.product_name,
	c.category_name,
	SUM(od.quantity) AS total_qty
FROM categories c
JOIN products p ON c.category_id = p.category_id
JOIN order_details od ON p.product_id = od.product_id
GROUP BY p.product_id, p.product_name, c.category_name
ORDER BY total_qty DESC;


6. Yearly revenue 

SELECT 
	EXTRACT (YEAR FROM o.order_date) AS year,
	ROUND(SUM(od.unit_price * od.quantity * (1-od.discount)),2) AS total_sales
FROM orders o
JOIN order_details od ON o.order_id = od.order_id
GROUP BY EXTRACT (YEAR FROM o.order_date)
ORDER BY year;


7. Growth % of each year

WITH yearly_sales AS(SELECT
	EXTRACT(YEAR FROM o.order_date) AS year,
	SUM(od.unit_price * od.quantity * (1-od.discount)) AS total_sales
FROM orders o
JOIN order_details od ON o.order_id = od.order_id
GROUP BY year)
SELECT
	year,
	total_Sales,
	(total_Sales - LAG(total_Sales) OVER (ORDER BY year))/LAG(total_sales) OVER (ORDER BY year) * 100
FROM yearly_sales
ORDER BY YEAR;


8. Top repeat customers vs one-time buyers 

WITH order_count AS(
	SELECT 
		customer_id,
		COUNT(order_id) AS total_orders
	FROM orders
		GROUP BY customer_id
		ORDER BY total_orders DESC
)
SELECT 
	CASE
		WHEN total_orders = 1 THEN 'one time'
		ELSE 'repeat'
		END AS customer_type,
	COUNT(*) AS customer_count
FROM order_count
GROUP BY customer_type;


9. Customer lifetime value (CLV) 

SELECT 
	c.customer_id,
	c.company_name,
	COUNT(od.order_id),
	ROUND(SUM(od.unit_price * od.quantity * (1-od.discount)),2) AS total_sales
FROM customers c
	JOIN orders o ON c.customer_id = o.customer_id
	JOIN order_details od ON o.order_id = od.order_id
GROUP BY c.customer_id, c.company_name
ORDER BY total_sales DESC;


10. Average order value per customer 

SELECT
	c.customer_id,
	c.company_name,
	COUNT(od.order_id),
	ROUND(SUM(od.quantity * od.unit_price * (1-od.discount)),2) AS total_sales,
	ROUND(AVG(od.quantity * od.unit_price * (1-od.discount)),2) AS avg_sales
FROM customers c 
JOIN orders o ON c.customer_id = o.customer_id
JOIN order_details od ON o.order_id = od.order_id
GROUP BY c.customer_id, c.company_name;


11. Customers who stopped ordering (churn detection)

SELECT
	customer_id,
	MAX(order_date) AS last_order_date
FROM orders
GROUP BY customer_id
HAVING MAX(order_date) < DATE '2015-05-06' - INTERVAL'90 Days'
ORDER BY last_order_date DESC;


12. Products that generate high revenue but low quantity (premium items) 

WITH product_stat AS (
	SELECT
		p.product_id,
		p.product_name,
		SUM(od.quantity * od.unit_price * (1-od.discount)) AS total_revenue,
		SUM(od.quantity) AS total_qty
	FROM products p
	JOIN order_details od ON p.product_id = od.product_id
	GROUP BY p.product_id, p.product_name
),
benchmark AS (
	SELECT
		AVG(total_revenue) AS avg_revenue,
		AVG(total_qty) AS avg_qty
	FROM product_stat	
)
SELECT 
	ps.product_id,
	ps.product_name,
	ROUND(ps.total_revenue,2),
	ps.total_qty,
	ROUND(b.avg_revenue,2),
	ROUND(b.avg_qty,2)
FROM product_stat ps
CROSS JOIN benchmark b
	WHERE ps.total_revenue > b.avg_revenue
	AND ps.total_qty > b.avg_qty
ORDER BY ps.total_revenue DESC;


13. Products with high quantity but low revenue (low margin candidates) 

WITH product_Stat AS (
	SELECT 
		p.product_id,
		p.product_name,
		p.unit_price,
		SUM(od.quantity) AS total_qty,
		ROUND(SUM(od.unit_price * od.quantity * (1-od.discount)),2) AS total_revenue
	FROM products p
	JOIN order_details od ON p.product_id = od.product_id
	GROUP BY p.product_id, p.product_name
),
benchmark AS (
	SELECT 
		ROUND(AVG(total_qty),2) AS avg_qty,
		ROUND(AVG(total_revenue),2) AS avg_revenue
	FROM product_stat
)
SELECT
	ps.product_id,
	ps.product_name,
	ps.unit_price,
	ps.total_qty,
	ps.total_revenue,
	b.avg_qty,
	b.avg_revenue
FROM product_stat ps
CROSS JOIN benchmark b 
	WHERE ps.total_revenue < b.avg_revenue
	AND ps.total_qty > b.avg_qty;


14. Slow-moving products (inventory insight)

WITH product_stat AS (
	SELECT
		p.product_id,
		p.product_name,
		SUM(od.quantity) AS total_qty
	FROM products p
	JOIN order_details od ON p.product_id = od.product_id
	GROUP BY p.product_id, p.product_name
),
benchmark AS (
	SELECT 
		ROUND(AVG(total_qty),2) AS avg_qty
	FROM product_Stat
)
SELECT
	ps.product_id,
	ps.product_name,
	ps.total_qty,
	b.avg_qty
FROM product_stat ps
CROSS JOIN benchmark b
	WHERE ps.total_qty < b.avg_qty;


15. Monthly sales trends (not just yearly) 

SELECT 
	EXTRACT(YEAR FROM o.order_date)::INT AS year,
	EXTRACT(MONTH FROM o.order_date)::INT AS month,
	ROUND(SUM(od.unit_price * od.quantity * (1-od.discount)),2) AS total_sales
FROM orders o
JOIN order_details od ON o.order_id = od.order_id
GROUP BY year, month
ORDER BY year,month;

"OR" 

SELECT 
	DATE_TRUNC('month', o.order_date) AS month,
	ROUND(SUM(od.unit_price * od.quantity * (1-od.discount)),2) AS total_sales
FROM orders o
JOIN order_details od ON o.order_id = od.order_id
GROUP BY month
ORDER BY month;


16. Best performing month/quarter 

WITH monthly_sales AS (
	SELECT 
		EXTRACT(MONTH FROM o.order_date) AS month,
		ROUND(SUM(od.unit_price * od.quantity * (1-od.discount)),2) AS total_sales
	FROM orders o 
	JOIN order_details od ON o.order_id = od.order_id
	GROUP BY month
)
SELECT 
	month,
	total_sales
FROM monthly_sales
ORDER BY total_sales DESC
LIMIT 1;

"OR"

WITH monthly_sales AS(
	SELECT
		EXTRACT(MONTH FROM o.order_date) AS month,
		ROUND(SUM(od.unit_price * od.quantity * (1-od.discount)),2) AS total_sales
	FROM orders o
	JOIN order_details od ON o.order_id = od.order_id
	GROUP BY month
)
SELECT 
	month,
	total_sales
FROM monthly_sales
WHERE total_sales = 
		(SELECT 	
			MAX(total_sales) 
		FROM monthly_sales);


17. Seasonality patterns

WITH monthly_sales AS (
	SELECT
		DATE_TRUNC('month', o.order_date) AS month,
		ROUND(SUM(od.unit_price * od.quantity * (1-od.discount)),2) AS total_sales
	FROM orders o
	JOIN order_details od ON o.order_id = od.order_id
	GROUP BY month
)
SELECT 
    EXTRACT(MONTH FROM month)::INT AS month_number,
    ROUND(AVG(total_sales), 2) AS avg_monthly_sales
FROM monthly_sales
GROUP BY month_number
ORDER BY month_number;


18. Orders not shipped yet 

SELECT 
	* 
FROM orders
WHERE shipped_date IS NULL;

"or"

SELECT 
    order_id,
    order_date,
    required_date,
    CURRENT_DATE - required_date AS delay_days
FROM orders
WHERE shipped_date IS NULL
  AND required_date < CURRENT_DATE;


19. Average shipping delay (shipped_date - order_date) 

SELECT 
	ROUND(AVG(shipping_days),2)
FROM
	(SELECT 
		shipped_date - order_date AS shipping_days
	 FROM orders)t;

"OR"

SELECT 
	ROUND(AVG(shipped_date - order_date),2) AS avg_shipping_days
FROM orders
WHERE shipped_date IS NOT NULL;


20. Shipper performance comparison

SELECT 
	s.shipper_id,
	s.company_name,
	COUNT(*) AS total_orders,
	AVG(o.freight) AS avg_freight,
	ROUND(AVG(shipped_date - order_date),2) AS avg_shipping_days
FROM shippers s
JOIN orders o ON s.shipper_id = o.shipper_id
WHERE shipped_date IS NOT NULL
GROUP BY s.shipper_id, s.company_name;


21. Revenue per employee 

SELECT 
	e.employee_id,
	e.employee_name,
	COUNT(DISTINCT o.order_id) AS total_orders,
	SUM(od.unit_price * od.quantity * (1-od.discount)) AS total_revenue
FROM employees e
JOIN orders o ON e.employee_id = o.employee_id
JOIN order_details od ON o.order_id = od.order_id
GROUP BY e.employee_id, e.employee_name
ORDER BY total_revenue DESC;


SELECT 
    e.employee_id,
    e.employee_name,
    COUNT(DISTINCT o.order_id) AS total_orders,
    SUM(od.unit_price * od.quantity * (1 - od.discount)) AS total_revenue,
    SUM(od.unit_price * od.quantity * (1 - od.discount)) 
        / COUNT(DISTINCT o.order_id) AS revenue_per_order
FROM employees e
JOIN orders o ON e.employee_id = o.employee_id
JOIN order_details od ON o.order_id = od.order_id
GROUP BY e.employee_id, e.employee_name
ORDER BY total_revenue DESC;


22. Average order value handled by each employee 

WITH total_revenue AS(	
	SELECT 
		e.employee_id AS employee_id,
		e.employee_name AS employee_name,
		SUM(od.unit_price * od.quantity * (1-od.discount)) AS revenue,
		COUNT(DISTINCT od.order_id) AS total_orders
	FROM order_details od
	JOIN orders o ON o.order_id = od.order_id
	JOIN employees e ON e.employee_id = o.employee_id
	GROUP BY e.employee_id, e.employee_name
)
SELECT
	employee_id,
	employee_name,
	(revenue / total_orders) AS avg_order_value
FROM total_revenue;


23. Employee contribution % to total sales

WITH employee_sales AS(
	SELECT
		e.employee_id,
		e.employee_name,
		SUM(od.unit_price * od.quantity * (1-discount)) AS total_revenue
	FROM employees e 
	JOIN orders o ON e.employee_id = o.employee_id
	JOIN order_details od ON o.order_id = od.order_id
	GROUP BY e.employee_id , e.employee_name
),
total_sales AS (
	SELECT
		SUM(od.unit_price * od.quantity * (1-od.discount)) AS revenue
	FROM order_details od
)
SELECT 
	es.employee_id,
	es.employee_name,
	(es.total_revenue/ts.revenue)*100 AS contribution_percentage
FROM employee_sales es
CROSS JOIN total_sales ts;	


24. Revenue per country normalized by number of customers 

SELECT
	country,
	total_revenue,
	customer_count,
	ROUND((total_revenue/customer_count),2)
FROM
	(SELECT 
	c.country,
	SUM(od.unit_price * od.quantity * (1-od.discount)) AS total_revenue,
	COUNT(DISTINCT c.customer_id) AS customer_count
FROM customers c 
JOIN orders o ON c.customer_id = o.customer_id 
JOIN order_details od ON o.order_id = od.order_id 
GROUP BY c.country
)t;


25. Expansion opportunities (countries with few customers but high spend)

WITH country_stats AS (
	SELECT 
		c.country,
		COUNT(DISTINCT c.customer_id) AS total_customers,
		SUM(od.unit_price * od.quantity * (1-od.discount)) AS total_revenue
	FROM customers c 
	JOIN orders o ON c.customer_id = o.customer_id
	JOIN order_details od ON o.order_id = od.order_id
	GROUP BY c.country
),
avg_stats AS(
	SELECT
		AVG(total_customers) AS avg_customers,
		AVG(total_revenue) AS avg_revenue
	FROM country_stats
)
SELECT
	cs.country,
	cs.total_customers,
	cs.total_revenue
FROM country_stats cs 
CROSS JOIN avg_stats a 
	WHERE 
		cs.total_customers < a.avg_customers
		AND cs.total_revenue > a.avg_revenue;


26. Average number of items per order 

SELECT 
	AVG(total_quantity)
FROM 
	(SELECT
	order_id,
	SUM(quantity) AS total_quantity
FROM order_details
GROUP BY order_id
)t;


26. Distribution of order sizes (small vs bulk orders)

WITH order_size AS (
	SELECT 
		order_id,
		SUM(quantity) AS total_qty
	FROM order_details
	GROUP BY order_id
),
avg_size AS(
	SELECT
		AVG(total_qty) AS avg_qty
	FROM order_size
)
SELECT
	CASE
		WHEN (o.total_qty > a.avg_qty) THEN 'Bulk'
		ELSE 'Small'
	END AS order_type,
	COUNT(*)
FROM order_size o
CROSS JOIN avg_size a
GROUP BY order_type;


26. High-value orders (top 10%)

SELECT 
	o.order_id,
	SUM(od.unit_price * od.quantity * (1-od.discount)) AS total_revenue
FROM orders o 
JOIN order_details od ON o.order_id = od.order_id
GROUP BY o.order_id


