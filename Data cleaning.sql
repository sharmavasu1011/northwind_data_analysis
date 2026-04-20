--Create tables

CREATE TABLE shippers(
	shipper_id INT PRIMARY KEY,
	company_name VARCHAR(100) NOT NULL
);

COPY shippers(shipper_id, company_name)
FROM 'C:\Users\vasu0\Desktop\sql practice\Northwind_Traders_datacleaning\data\shippers.csv'
WITH(FORMAT CSV, HEADER, DELIMITER ',');

SELECT * FROM shippers;




CREATE TABLE categories(
	category_id INT PRIMARY KEY,
	category_name VARCHAR(100) NOT NULL,
	description VARCHAR (1000)
);

COPY categories (category_id, category_name, description)
FROM 'C:\Users\vasu0\Desktop\sql practice\Northwind_Traders_datacleaning\data\categories.csv'
WITH (FORMAT CSV, HEADER, DELIMITER ',');

SELECT * FROM categories;




CREATE TABLE products(
	product_id INT PRIMARY KEY,
	product_name VARCHAR (200),
	quantity_per_unit VARCHAR(100),
	unit_price DECIMAL (10,2),
	discontinued BOOLEAN,
	category_id INT,
	FOREIGN KEY (category_id) REFERENCES categories (category_id)
);

ALTER TABLE products
	DROP COLUMN category_id;

ALTER TABLE products
	ADD COLUMN category_id INT,
	ADD CONSTRAINT fk_products_categories
	FOREIGN KEY (category_id) 
	REFERENCES categories(category_id);
	
COPY products (product_id, product_name, quantity_per_unit, unit_price, discontinued, category_id)
FROM 'C:\Users\vasu0\Desktop\sql practice\Northwind_Traders_datacleaning\data\products.csv'
WITH (FORMAT CSV, HEADER, DELIMITER ',');

SELECT * FROM products;




CREATE TABLE employees(
	employee_id INT PRIMARY KEY,
	employee_name VARCHAR(100),
	title VARCHAR(100),
	city VARCHAR(100),
	country VARCHAR(100),
	reports_to INT
);

COPY employees (employee_id, employee_name, title, city, country, reports_to)
FROM 'C:\Users\vasu0\Desktop\sql practice\Northwind_Traders_datacleaning\data\employees.csv'
WITH (FORMAT CSV, HEADER, DELIMITER ',');

SELECT * FROM employees;




CREATE TABLE customers(
	customer_id VARCHAR(100) PRIMARY KEY,
	company_name VARCHAR(100),
	contact_name VARCHAR(100),
	contact_title VARCHAR(100),
	city VARCHAR(100),
	country VARCHAR(100)
);

COPY customers (customer_id, company_name, contact_name, contact_title, city, country)
FROM 'C:\Users\vasu0\Desktop\sql practice\Northwind_Traders_datacleaning\data\customers.csv'
WITH (FORMAT CSV, HEADER, DELIMITER ',');

SELECT * FROM customers;




CREATE TABLE orders(
	order_id INT PRIMARY KEY,
	customer_id VARCHAR(100),
	employee_id INT,
	order_date DATE,
	required_date DATE,
	shipped_date DATE,
	shipper_id INT ,
	freight DECIMAL(10,2),
	FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
	FOREIGN KEY (employee_id) REFERENCES employees(employee_id),
	FOREIGN KEY (shipper_id) REFERENCES shippers(shipper_id)
);

COPY orders (order_id, customer_id, employee_id, order_date, required_date, shipped_date, shipper_id, freight)
FROM 'C:\Users\vasu0\Desktop\sql practice\Northwind_Traders_datacleaning\data\orders.csv'
WITH (FORMAT CSV, HEADER, DELIMITER ',');

SELECT * FROM orders;




CREATE TABLE order_details(
	order_id INT,
	product_id INT,
	unit_price DECIMAL(10,2),
	quantity INT,
	discount DECIMAL (10,2),
	FOREIGN KEY (order_id) REFERENCES orders(order_id),
	FOREIGN KEY (product_id) REFERENCES products(product_id)
);

COPY order_details (order_id, product_id, unit_price, quantity, discount)
FROM 'C:\Users\vasu0\Desktop\sql practice\Northwind_Traders_datacleaning\data\order_details.csv'
WITH (FORMAT CSV, HEADER, DELIMITER ',');

SELECT * FROM order_details;




