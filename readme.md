Northwind sales and operations analysis

Overview
This project analyzes the Northwind dataset to uncover insights into customer behavior, product performance, sales trends, and operational efficiency. 
PostgreSQL was used for data cleaning and analysis, while Excel was used to build an interactive dashboard to visualize key findings.

Objective
- Identify top customers and their contribution to total revenue 
- Analyze product performance and sales distribution 
- Evaluate operational efficiency and shipping delays 
- Identify top-performing employees and regions 
- Analyze monthly revenue trends

Data Cleaning
- Removed records with missing or invalid values (e.g., NULL quantity or unit price) 
- Standardized discount values by replacing NULLs with 0 
- Validated data integrity (e.g., checking for invalid discount ranges < 0 or > 1) 
- Verified key fields such as order_id for consistency

Analysis & Insights
# customer analysis
- Top 10% of customers contributes approximately 40% of total revenue, indicating high customer concentration 
- Identified repeat vs one-time customers to understand retention patterns 

# product analysis
- Revenue is driven by a subset of high-performing products 
- Identified premium and low-margin products to evaluate profitability 
- Discounts contribute to $88,665.55 revenue loss, indicating potential inefficiencies in pricing strategy 

# Shipping & Operations
- Orders were categorized into timely, delayed, and not shipped to evaluate operational #performance 
- Certain employees are associated with higher delays, indicating potential process inefficiencies 
- Average shipping cost varies across orders, impacting overall profitability 

# Revenue Trends
- Monthly revenue analysis reveals fluctuations and potential seasonality 
- Product demand varies across countries, indicating region-specific preferences

Dashboard
 
The Excel dashboard provides an interactive overview of:
- Total orders and total revenue 
- Customer segmentation (one-time vs repeat customers) 
- Top 5 customers and products 
- Sales performance by employee 
- Monthly revenue trends with year-based filtering 
- Shipping performance (timely, delayed, not shipped)

Tools used
-	PostgreSQL
-	Excel (Pivot Tables, Dashboard, Data Analysis)

Project Structure

#Northwind_traders
┣Data cleaning
┣Defining goal
┣dashboard
┣schema
┣readme

