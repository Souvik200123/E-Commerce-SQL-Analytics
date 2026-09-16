# E-Commerce Sales & Customer Analytics using SQL

## 📌 Project Overview

This project analyzes the Brazilian E-Commerce Public Dataset by Olist using MySQL.

The objective is to analyze e-commerce sales, customer behavior, product performance, seller performance, payment methods, customer reviews, and delivery efficiency using SQL.

The project demonstrates practical SQL skills ranging from basic data exploration to advanced analytical techniques such as CTEs, subqueries, window functions, ranking, and customer segmentation.

---

## 🎯 Business Objectives

- Analyze overall sales and revenue trends
- Identify monthly revenue growth
- Identify top-performing products and categories
- Analyze customer purchasing behavior
- Identify high-value and repeat customers
- Evaluate seller performance
- Analyze payment methods
- Analyze customer reviews
- Evaluate delivery performance
- Identify high-performing geographic regions

---

## 🗂️ Dataset

**Brazilian E-Commerce Public Dataset by Olist**

The dataset contains approximately 100K e-commerce orders from 2016–2018 across multiple relational tables.

### Main Tables

| Table | Description |
|---|---|
| customers | Customer information and location |
| sellers | Seller information and location |
| products | Product details and categories |
| orders | Order status and timestamps |
| order_items | Products purchased in each order |
| order_payments | Payment information |
| order_reviews | Customer review information |
| geolocation | Brazilian ZIP-code geographical data |
| product_category_translation | Product category translation |

---

## 🛠️ Tools & Technologies

- MySQL 8.0
- MySQL Workbench
- SQL
- VS Code
- Git & GitHub

---

## 🧠 SQL Skills Demonstrated

### Basic SQL
- SELECT
- WHERE
- GROUP BY
- ORDER BY
- HAVING
- DISTINCT
- Aggregate Functions

### Intermediate SQL
- INNER JOIN
- LEFT JOIN
- Subqueries
- CASE WHEN
- Conditional Aggregation
- Date Functions
- Data Quality Checks

### Advanced SQL
- Common Table Expressions (CTEs)
- Window Functions
- LAG()
- DENSE_RANK()
- Running Totals
- Moving Averages
- Revenue Contribution Analysis
- Customer Segmentation
- Ranking within Groups

---

## 📊 Analysis Performed

### Sales Analysis
- Total orders
- Total revenue
- Average order value
- Monthly revenue
- Month-over-month growth
- Revenue by state
- High-value orders

### Customer Analysis
- Unique customers
- Customer spending
- Repeat customers
- One-time customers
- Customer segmentation
- Customer ranking

### Product Analysis
- Product categories
- Units sold
- Revenue by category
- Top products
- Average selling price
- Unsold products
- Seller performance

### Delivery Analysis
- Average delivery time
- On-time delivery percentage
- Late delivery percentage
- Delivery delays
- Delivery performance by state
- Monthly delivery performance

### Advanced SQL Analysis
- Monthly revenue growth using LAG()
- Top products within categories
- Top sellers within states
- Customer revenue ranking
- Running cumulative revenue
- Three-month moving average
- Revenue contribution analysis
- Customer segmentation

---

## 📁 Project Structure

```text
E-Commerce-SQL-Analytics/
│
├── Data/
│
├── sql/
│   ├── 01_database_setup.sql
│   ├── 02_data_exploration.sql
│   ├── 03_data_quality.sql
│   ├── 04_sales_analysis.sql
│   ├── 05_customer_analysis.sql
│   ├── 06_product_analysis.sql
│   ├── 07_delivery_analysis.sql
│   └── 08_advanced_sql.sql
│
├── screenshots/
│
└── README.md
## Key Business Insights

The analysis focuses on identifying:

- Major revenue-generating states
- High-performing product categories
- Top-performing sellers
- High-value customers
- Repeat-purchase behavior
- Popular payment methods
- Customer satisfaction patterns
- Delivery efficiency
- Monthly sales trends
- Revenue concentration

## SQL Files

| File | Purpose |
|---|---|
| `01_database_setup.sql` | Creates database and tables |
| `02_data_exploration.sql` | Initial data exploration |
| `03_data_quality.sql` | Data validation and quality checks |
| `04_sales_analysis.sql` | Sales and revenue analysis |
| `05_customer_analysis.sql` | Customer behavior analysis |
| `06_product_analysis.sql` | Product and seller analysis |
| `07_delivery_analysis.sql` | Delivery and logistics analysis |
| `08_advanced_sql.sql` | Advanced SQL analysis |

## How to Run

1. Install MySQL 8.0.
2. Create the `ecommerce_sql_analysis` database.
3. Run `01_database_setup.sql` to create the tables.
4. Load the Olist CSV files into the corresponding tables.
5. Run the SQL analysis files in order.

## Dataset Source

**Brazilian E-Commerce Public Dataset by Olist**

The dataset is publicly available on Kaggle.

This project is an independent SQL analysis created for learning and portfolio purposes.

## Author

**Souvik Maji**

Aspiring Data Analyst

**Skills:** SQL | Python | Excel | Power BI | Data Analysis

**GitHub:** Souvik200123

**LinkedIn:** souvikmaji23