--defining goal



--best customer

SELECT 
	c.customer_id,
	c.company_name,
	SUM(od.unit_price * od.quantity * (1-od.discount)) AS total_revenue
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN order_details od ON o.order_id = od.order_id
GROUP BY c.customer_id, c.company_name
ORDER BY total_revenue DESC
LIMIT 1;


--average order value

SELECT 
	AVG(unit_price * quantity * (1-discount)) AS average_order_value
FROM order_details;


--most selling product

SELECT
	p.product_id,
	p.product_name,
	SUM(od.unit_price * od.quantity * (1-od.discount)) AS total_sales
FROM products p
JOIN order_details od ON p.product_id = od.product_id
GROUP BY p.product_id, p.product_name
ORDER BY total_sales DESC
LIMIT 1;

	
--most selling product for each country

WITH country_sales AS(
	SELECT
		c.country,
		p.product_id,
		p.product_name,
		SUM(od.unit_price * od.quantity * (1-od.discount)) AS total_revenue,
		ROW_NUMBER () OVER (PARTITION BY c.country ORDER BY SUM(od.unit_price * od.quantity * (1-od.discount)) DESC) AS rnk
	FROM customers c
	JOIN orders o ON c.customer_id = o.customer_id
	JOIN order_details od ON o.order_id = od.order_id
	JOIN products p ON od.product_id = p.product_id
	GROUP BY c.country,	p.product_id, p.product_name
)
SELECT
	country,
	product_id,
	product_name,
	total_revenue,
	rnk
FROM country_sales
WHERE rnk = 1;


--least selling product

SELECT 
	p.product_id,
	p.product_name,
	SUM(od.unit_price * od.quantity * (1-od.discount)) AS total_revenue
FROM products p
JOIN order_details od ON p.product_id = od.product_id
GROUP BY p.product_id, p.product_name
ORDER BY total_revenue
LIMIT 1;


--most selling product with least discount

WITH product_stat AS(
	SELECT
		p.product_id,
		p.product_name,
		AVG(od.discount) AS avg_discount,
		SUM(od.unit_price * od.quantity * (1-od.discount)) AS total_revenue
	FROM products p
	JOIN order_details od ON p.product_id = od.product_id
	GROUP BY p.product_id, p.product_name
),
ranks AS(
	SELECT
		*,
		ROW_NUMBER() OVER(ORDER BY avg_discount, total_revenue DESC) AS rnk
	FROM product_stat
)
SELECT
	*
FROM ranks
WHERE rnk = 1;


--revenue lost due to discount

SELECT 
	SUM(unit_price * quantity) AS total_revenue,
	SUM(unit_price * quantity * discount) AS discount,
	SUM(unit_price * quantity) - SUM(unit_price * quantity * discount) AS discounted_revenue
FROM order_details;


--country and city with most sales

WITH country_stats AS(
	SELECT 
		c.country,
		c.city,
		SUM(od.unit_price * od.quantity * (1-od.discount)) AS total_revenue,
		ROW_NUMBER () OVER (PARTITION BY c.country ORDER BY SUM(od.unit_price * od.quantity * (1-od.discount)) DESC) AS rnk
	FROM customers c
	JOIN orders o ON c.customer_id = o.customer_id
	JOIN order_details od ON o.order_id = od.order_id
	GROUP BY c.country, c.city
)
SELECT
	*
FROM country_stats
WHERE rnk = 1;


--premium products

WITH product_stat AS(
	SELECT 
		p.product_id,
		p.product_name,
		SUM(od.quantity) AS total_qty,
		SUM(od.unit_price * od.quantity * (1-od.discount)) AS total_revenue
	FROM products p
	JOIN order_details od ON p.product_id = od.product_id
	GROUP BY p.product_id , p.product_name
),
benchmark AS(
	SELECT
		AVG(total_qty) AS avg_qty,
		AVG(total_revenue) AS avg_revenue
	FROM product_stat
)
SELECT
	ps.product_id,
	ps.product_name,
	ps.total_revenue,
	b.avg_revenue,
	ps.total_qty,
	b.avg_qty
FROM product_stat ps
CROSS JOIN benchmark b
WHERE 
	ps.total_revenue > b.avg_revenue
	AND ps.total_qty < b.avg_qty;
		

--low margin products

WITH product_stat AS (
	SELECT
		p.product_id,
		p.product_name,
		SUM(od.quantity) AS total_qty,
		SUM(od.unit_price * od.quantity * (1-od.discount)) AS total_revenue
	FROM products p
	JOIN order_details od ON p.product_id = od.product_id
	GROUP BY p.product_id, p.product_name
),
benchmark AS(
	SELECT
		AVG(total_qty) AS avg_qty,
		AVG(total_revenue) AS avg_revenue
	FROM product_stat
)
SELECT
	ps.product_id,
	ps.product_name,
	ps.total_qty,
	b.avg_qty,
	ps.total_revenue,
	b.avg_revenue
FROM product_stat ps
CROSS JOIN benchmark b
WHERE 
	ps.total_qty > b.avg_qty
	AND ps.total_revenue < b.avg_revenue;

	
--employee with most sales or revenue

SELECT
	e.employee_id,
	e.employee_name,
	SUM(od.unit_price * od.quantity *(1-od.discount)) AS total_revenue
FROM employees e
JOIN orders o ON e.employee_id = o.employee_id
JOIN order_details od ON o.order_id = od.order_id
GROUP BY e.employee_id, e.employee_name
ORDER BY total_revenue DESC
LIMIT 1;

--timely shipped orders

SELECT
	* 
FROM orders
WHERE shipped_date < required_date;


--delayed shipped product

SELECT 
	*
FROM orders
WHERE required_date < shipped_date;


--products not shipped

SELECT
	*
FROM orders
WHERE shipped_date IS NULL;


--average shipping cost per country

SELECT
	c.country,
	AVG(o.freight) AS shipping_cost
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.country;


--which employee caused most delays

SELECT 
	e.employee_id,
	e.employee_name,
	COUNT(o.order_id) AS order_count
FROM employees e 
JOIN orders o ON e.employee_id = o.employee_id
WHERE
	o.shipped_date > o.required_date
	OR o.shipped_date IS NULL
GROUP BY e.employee_id, e.employee_name
ORDER BY order_count DESC;



--monthly revenue

SELECT
	EXTRACT(MONTH FROM o.order_date) AS months,
	EXTRACT(YEAR FROM o.order_date) AS years,
	SUM(od.unit_price * od.quantity * (1-od.discount)) AS total_revenue
FROM orders o
JOIN order_details od ON o.order_id = od.order_id
GROUP BY 
	EXTRACT(MONTH FROM o.order_date),
	EXTRACT(YEAR FROM o.order_date)
ORDER BY years, months;


--best performing month

SELECT
	DATE_TRUNC('month',o.order_date) AS months,
	SUM(od.unit_price * od.quantity * (1-od.discount)) AS total_revenue
FROM orders o
JOIN order_details od ON o.order_id = od.order_id
GROUP BY DATE_TRUNC('month',o.order_date)
ORDER BY total_revenue DESC
LIMIT 1;


--repeat vs one time customers

WITH customer_order AS(
	SELECT
		c.customer_id,
		c.company_name,
		COUNT(DISTINCT o.order_id) AS total_orders
	FROM customers c
	JOIN orders o ON c.customer_id = o.customer_id
	GROUP BY 
		c.customer_id,
		c.company_name
)
SELECT
	CASE 
		WHEN total_orders > 1 THEN 'Repeat'
		ELSE 'One time'
	END AS customer_type,
	COUNT(*) AS customers_count
FROM customer_order
GROUP BY customer_type;


--largest order

WITH order_tables AS(
	SELECT
		order_id,
		SUM(unit_price * quantity * (1-discount)) AS total_revenue
	FROM order_details
	GROUP BY order_id
)
SELECT
	order_id,
	total_revenue
FROM order_tables
	WHERE total_revenue = (SELECT MAX(total_revenue) FROM order_tables);