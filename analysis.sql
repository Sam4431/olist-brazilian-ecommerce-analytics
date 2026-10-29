/*
Brazilian E-Commerce Analytics (Olist) — analysis.sql

Definitions:
- Product revenue/spend and AOV use order_items.price; freight is excluded.
- Only delivered orders are included.
- Customers are grouped by customer_unique_id.
- English category names are used when available, otherwise Portuguese names.
- Revenue is not profit.
*/

-- Q1. Which product categories generate the highest total product revenue?
SELECT
    COALESCE(ct.product_category_name_english, p.product_category_name) AS product_category,
    ROUND(SUM(oi.price), 2) AS total_product_revenue
FROM orders AS o
JOIN order_items AS oi ON o.order_id = oi.order_id
JOIN products AS p ON oi.product_id = p.product_id
LEFT JOIN category_translation AS ct
    ON p.product_category_name = ct.product_category_name
WHERE o.order_status = 'delivered'
  AND p.product_category_name IS NOT NULL
GROUP BY COALESCE(ct.product_category_name_english, p.product_category_name)
ORDER BY total_product_revenue DESC;


-- Q2. What share of delivered-order product spending comes from the top 10%?
-- Top 10% is calculated dynamically; CEIL rounds the customer count upward.
WITH customer_totals AS (
    SELECT c.customer_unique_id, SUM(oi.price) AS total_spend
    FROM orders AS o
    JOIN order_items AS oi ON o.order_id = oi.order_id
    JOIN customers AS c ON o.customer_id = c.customer_id
    WHERE o.order_status = 'delivered'
    GROUP BY c.customer_unique_id
),
ranked_customers AS (
    SELECT
        customer_unique_id,
        total_spend,
        ROW_NUMBER() OVER (ORDER BY total_spend DESC, customer_unique_id) AS customer_rank,
        COUNT(*) OVER () AS eligible_customer_count
    FROM customer_totals
),
summary AS (
    SELECT
        SUM(CASE WHEN customer_rank <= CEIL(eligible_customer_count * 0.10)
                 THEN total_spend ELSE 0 END) AS top_10_spend,
        SUM(total_spend) AS overall_spend,
        MAX(eligible_customer_count) AS eligible_customers,
        MAX(CEIL(eligible_customer_count * 0.10)) AS top_10_customer_count
    FROM ranked_customers
)
SELECT
    eligible_customers,
    top_10_customer_count,
    ROUND(top_10_spend, 2) AS top_10_spend,
    ROUND(overall_spend, 2) AS overall_product_spend,
    ROUND(100 * top_10_spend / overall_spend, 2) AS spending_share_pct
FROM summary;


-- Optional Q2 detail: list each customer in the top 10%.
WITH customer_totals AS (
    SELECT c.customer_unique_id, SUM(oi.price) AS total_spend
    FROM orders AS o
    JOIN order_items AS oi ON o.order_id = oi.order_id
    JOIN customers AS c ON o.customer_id = c.customer_id
    WHERE o.order_status = 'delivered'
    GROUP BY c.customer_unique_id
),
ranked_customers AS (
    SELECT
        customer_unique_id,
        total_spend,
        ROW_NUMBER() OVER (ORDER BY total_spend DESC, customer_unique_id) AS customer_rank,
        COUNT(*) OVER () AS eligible_customer_count
    FROM customer_totals
)
SELECT customer_unique_id, ROUND(total_spend, 2) AS total_spend, customer_rank
FROM ranked_customers
WHERE customer_rank <= CEIL(eligible_customer_count * 0.10)
ORDER BY customer_rank;


-- Q3. How does average order value (AOV) vary by Brazilian state?
-- First total item prices within each order, then average order totals by state.
WITH order_totals AS (
    SELECT o.order_id, o.customer_id, SUM(oi.price) AS order_value
    FROM orders AS o
    JOIN order_items AS oi ON o.order_id = oi.order_id
    WHERE o.order_status = 'delivered'
    GROUP BY o.order_id, o.customer_id
)
SELECT
    c.customer_state,
    COUNT(ot.order_id) AS delivered_orders,
    ROUND(AVG(ot.order_value), 2) AS average_order_value
FROM order_totals AS ot
JOIN customers AS c ON ot.customer_id = c.customer_id
GROUP BY c.customer_state
ORDER BY average_order_value DESC;


-- Q4A. Which categories have the highest average review score?
-- Limitation: reviews are order-level, not product-level. A review score is
-- associated with each category in the order, so these are category-associated
-- order review scores, not ratings of individual products.
SELECT
    COALESCE(ct.product_category_name_english, p.product_category_name) AS product_category,
    ROUND(AVG(r.review_score), 2) AS average_review_score,
    COUNT(DISTINCT r.order_id) AS reviewed_orders
FROM order_reviews AS r
JOIN orders AS o ON r.order_id = o.order_id
JOIN order_items AS oi ON o.order_id = oi.order_id
JOIN products AS p ON oi.product_id = p.product_id
LEFT JOIN category_translation AS ct
    ON p.product_category_name = ct.product_category_name
WHERE o.order_status = 'delivered'
  AND p.product_category_name IS NOT NULL
  AND r.review_score IS NOT NULL
GROUP BY COALESCE(ct.product_category_name_english, p.product_category_name)
ORDER BY average_review_score DESC;


-- Q4B. What percentage of customers made at least two delivered purchases
-- containing the same category? This measures repeat purchasing within a
-- category, not all-cause customer retention, and does not establish causation.
WITH customer_category_orders AS (
    SELECT DISTINCT
        c.customer_unique_id,
        COALESCE(ct.product_category_name_english, p.product_category_name) AS product_category,
        o.order_id
    FROM orders AS o
    JOIN customers AS c ON o.customer_id = c.customer_id
    JOIN order_items AS oi ON o.order_id = oi.order_id
    JOIN products AS p ON oi.product_id = p.product_id
    LEFT JOIN category_translation AS ct
        ON p.product_category_name = ct.product_category_name
    WHERE o.order_status = 'delivered'
      AND p.product_category_name IS NOT NULL
),
customer_category_counts AS (
    SELECT customer_unique_id, product_category, COUNT(DISTINCT order_id) AS category_orders
    FROM customer_category_orders
    GROUP BY customer_unique_id, product_category
)
SELECT
    product_category,
    COUNT(*) AS customers,
    SUM(category_orders >= 2) AS repeat_customers,
    ROUND(100.0 * SUM(category_orders >= 2) / COUNT(*), 2) AS repeat_purchase_rate_pct
FROM customer_category_counts
GROUP BY product_category
ORDER BY repeat_purchase_rate_pct DESC, customers DESC;


/*
Recorded findings from the run (rerun queries if the data changes):

Q1: Health and beauty led at about R$1,233,131.72, followed by watches and
gifts (R$1,166,176.98), bed/bath/table (R$1,023,434.76), sports/leisure
(R$954,852.55), and computers/accessories (R$888,724.61).

Q2: 93,358 eligible customers; top 10% rounded up to 9,336 customers.
Top-group spend R$5,434,024.58 of R$13,221,498.11 overall = 41.10%.

Q3: Highest AOV was Paraíba (PB), R$217.77 across 517 delivered orders.
Lowest was São Paulo (SP), R$125.12 across 40,501 delivered orders.

Q4: Fashion children's clothes scored 5.00 across only 7 reviewed orders,
too small a sample for a strong conclusion. Books general interest scored
4.51 across 492 reviewed orders. Home appliances had a 7.27% same-category
repeat rate (50/688). Arts and craftmanship had 9.52% (2/21), but its sample
was small. These results do not establish that review scores cause repeat buying.
*/
