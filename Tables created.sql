CREATE TABLE shippers(
	shipper_id INT PRIMARY KEY,
	company_name VARCHAR(50) NOT NULL
);

COPY shippers(shipper_id, company_name)
FROM 'C:\Users\vasu0\Downloads\archive (4)\shippers.csv'
WITH (FORMAT CSV, HEADER, DELIMITER ',');

SELECT * FROM shippers;


CREATE TABLE employees(
	employee_id INT PRIMARY KEY,
	employee_name VARCHAR(50),
	title VARCHAR(50),
	city VARCHAR(50),
	country VARCHAR(50),
	reports_to INT 
);

ALTER TABLE employees
ADD CONSTRAINT fk_reports_to
FOREIGN KEY (reports_to)
REFERENCES employees(employee_id);

COPY employees(employee_id, employee_name, title, city, country, reports_to)
FROM 'C:\Users\vasu0\Downloads\archive (4)\employees.csv'
WITH (FORMAT CSV, HEADER, DELIMITER ',');

SELECT * FROM employees;


CREATE TABLE categories(
	category_id INT PRIMARY KEY,
	category_name VARCHAR(50),
	description VARCHAR(200)
);

copy categories(category_id, category_name, description)
FROM 'C:/Users/vasu0/Downloads/archive (4)/categories.csv'
WITH (FORMAT CSV, HEADER, DELIMITER ',');

SELECT * FROM categories;


CREATE TABLE customers(
	customer_id VARCHAR(50) PRIMARY KEY,
	company_name VARCHAR(100),
	contact_name VARCHAR(100),
	contact_title VARCHAR(100),
	city VARCHAR(50),
	country VARCHAR(50)
);

COPY customers(customer_id, company_name, contact_name, contact_title, city, country)
FROM 'C:\Users\vasu0\Downloads\archive (4)\customers.csv'
WITH (FORMAT CSV, HEADER, DELIMITER ',');

SELECT * FROM customers;


CREATE TABLE products(
	product_id INT PRIMARY KEY,
	product_name VARCHAR(200),
	quantity_per_unit VARCHAR(50),
	unit_price DECIMAL(10,2),
	discontinued BOOLEAN,
	category_id INT,
	FOREIGN KEY (category_id) REFERENCES categories(category_id)
);

ALTER TABLE products
ALTER COLUMN unit_price TYPE DECIMAL(10,2), 
ALTER COLUMN unit_price SET NOT NULL;

COPY products(product_id, product_name, quantity_per_unit, unit_price, discontinued, category_id)
FROM 'C:\Users\vasu0\Downloads\archive (4)\products.csv'
WITH (FORMAT CSV, HEADER, DELIMITER ',');

SELECT * FROM products;


CREATE TABLE orders(
	order_id INT PRIMARY KEY,
	customer_id VARCHAR(50),
	employee_id INT,
	order_date DATE,
	required_date DATE,
	shipped_date DATE,
	shipper_id INT,
	freight DECIMAL(10,2),
	FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
	FOREIGN KEY (employee_id) REFERENCES employees(employee_id),
	FOREIGN KEY (shipper_id) REFeRENCES shippers(shipper_id)
);

COPY orders(order_id, customer_id, employee_id, order_date, required_date, shipped_date, shipper_id, freight)
FROM 'C:\users\vasu0\downloads\archive (4)\orders.csv'
WITH (FORMAT CSV, HEADER, DELIMITER ',');

SELECT * FROM orders;


CREATE TABLE order_Details(
	order_id INT,
	product_id INT,
	unit_price INT,
	quantity INT,
	discount DECIMAL(10,2),
	FOREIGN KEY (order_id) REFERENCES orders(order_id),
	FOREIGN KEY (product_id) REFERENCES products(product_id)
);

ALTER TABLE order_details
ADD CONSTRAINT pk_order_details PRIMARY KEY (order_id, product_id),
ALTER COLUMN unit_price TYPE DEC(10,2);

COPY order_details(order_id, product_id, unit_price, quantity, discount)
FROM 'c:\users\vasu0\downloads\archive (4)\order_details.csv'
WITH (FORMAT CSV, HEADER, DELIMITER ',');

SELECT * FROM order_details;