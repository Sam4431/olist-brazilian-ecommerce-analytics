# Brazilian E-Commerce Analytics (Olist)

A SQL portfolio project analyzing the Brazilian Olist e-commerce marketplace using MySQL. The project turns raw marketplace data into findings about product-category sales, customer spending concentration, average order value by state, and category-associated reviews and repeat purchasing.

## Business questions

1. **Which product categories generate the highest total product revenue?**
2. **What share of delivered-order product spending comes from the top 10% of customers?**
3. **How does average order value (AOV) vary by Brazilian state?**
4. **Which categories have high review scores, and do those scores align with repeat purchases?**

## Key findings

- **Health & beauty** generated the highest delivered-item sales at approximately **R$1.23 million**, followed by **watches & gifts** (R$1.17 million) and **bed/bath/table** (R$1.02 million).
- The top **9,336 unique customers** accounted for approximately **R$5.43 million**, or **41.10%** of delivered-order product spending in the analysis.
- **Paraíba (PB)** had the highest average delivered order value (**R$217.77**). **São Paulo (SP)** had the lowest (**R$125.12**) but the largest order volume, with **40,501** delivered orders.
- **Home appliances** showed a **7.27%** category repeat-purchase rate (50 repeat customers among 688). Some categories with very high review scores had very small samples, so those rankings should be interpreted cautiously.
- High revenue, high AOV, high review scores, and high repeat-purchase rates measure different things. The analysis does not establish causation or profitability.

See [`reports/stage3-insights-report.pdf`](reports/stage3-insights-report.pdf) for the findings table, recommended investment priorities, growth recommendation, and interpretation notes.

## Recommended growth tests

1. **Health & beauty:** test replenishment reminders, bundles, and post-purchase offers to encourage a second purchase.
2. **Home appliances:** test complementary products or accessories and evaluate repeat behavior over an appropriate time window.
3. **Watches & gifts:** test occasion-based promotions, gift bundles, and cross-category recommendations.

These are hypotheses to test, not guaranteed winners. Track incremental orders, conversion, repeat-purchase rate, and contribution margin before scaling.

## Tools and methods

- **Database:** MySQL 8.0
- **SQL techniques:** joins, aggregation, common table expressions (CTEs), window functions, conditional aggregation, type conversion, data-quality checks, and relational schema design.
- **Preparation approach:** raw CSV source tables are preserved separately; working tables use appropriate data types. Empty strings are converted to `NULL`, numeric values are cast, and timestamp text is parsed.
- **Metric definitions:** product sales/spend and AOV use `order_items.price`; freight is excluded. The main sales analyses include delivered orders only. Customers are grouped by `customer_unique_id` so multiple order-level customer records can be combined.

## Repository structure

```text
olist-brazilian-ecommerce-analytics/
├── README.md
├── schema.sql
├── data_preparation.sql
├── analysis.sql
└── reports/
    └── stage3-insights-report.pdf
```

## Data source

The project uses the **Brazilian E-Commerce Public Dataset by Olist**, commonly distributed through Kaggle:

- https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce

The dataset contains multiple CSV files covering orders, order items, products, customers, sellers, payments, reviews, geolocation, and product-category translations. The source CSVs are not included in this repository; download them from the dataset source and import them into MySQL before running the scripts.

## How to run

Run the scripts in this order.

### 1. Create/select a database

Create a database in MySQL Workbench, for example:

```sql
CREATE DATABASE brazilian_ecommerce;
USE brazilian_ecommerce;
```

Select that database as the active schema before running the scripts. `schema.sql` is a structure-only export and does not create or select the database itself.

### 2. Import the raw CSV files

Import the nine source CSVs as raw tables with the original column names. The table names expected by `data_preparation.sql` are:

- `olist_customers_dataset`
- `olist_sellers_dataset`
- `olist_products_dataset`
- `product_category_name_translation`
- `olist_orders_dataset`
- `olist_order_items_dataset`
- `olist_order_payments_dataset`
- `olist_order_reviews_dataset`
- `olist_geolocation_dataset`

For this project, the raw tables were imported with source fields retained as text, then transformed into typed working tables. If you use a different import configuration, check that column names and types are compatible with the preparation script.

### 3. Create the working tables

Open and execute [`schema.sql`](schema.sql). It creates the normalized working tables and their keys/indexes.

**Important:** this script contains `DROP TABLE IF EXISTS` statements for the working tables. Running it again will drop and recreate those working tables. It does not drop the raw source tables.

### 4. Prepare the data

Execute [`data_preparation.sql`](data_preparation.sql). It inserts transformed records from the raw tables into the working tables.

**Important:** this script uses `INSERT` statements. Do not run it twice against already populated working tables, or you may encounter duplicate-key errors or duplicated rows. For a clean rebuild, intentionally rerun `schema.sql` first, then rerun the preparation script.

### 5. Run the analysis

Execute [`analysis.sql`](analysis.sql). It contains the queries for the four business questions, including an optional customer-level detail query for the top-spending customer segment.

## Data quality and interpretation notes

- Product-category translations are used when available; Portuguese category names remain as a fallback where an English translation is missing.
- Products with missing category values are excluded from category-level results.
- Product price is used without freight. Therefore, the report's “revenue” wording refers to delivered-item sales value and should **not** be interpreted as profit or complete accounting revenue.
- AOV is calculated by summing item prices within each delivered order first, then averaging order totals by customer state.
- The customer concentration calculation uses `customer_unique_id`, not `customer_id`, because the latter can represent a customer record associated with an individual order.
- Olist reviews are attached to orders rather than individual products. A review score associated with a category can therefore reflect the overall order experience and may be associated with multiple categories when an order contains items from multiple categories.
- Small samples can produce unstable rankings. For example, a category with a perfect average review score across only a handful of reviewed orders is not directly comparable to one with hundreds or thousands.
- The analysis is descriptive. It does not prove that a category causes repeat purchases or that a proposed campaign will be profitable.


