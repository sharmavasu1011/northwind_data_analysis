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

	
--employee with mose sales or revenue


timely shipped product
delayed shipped product
products not shipped
average shipping cost per country
which employee caused most delays
monthly revenue
best performing month
repeat vs one time customers
larges order