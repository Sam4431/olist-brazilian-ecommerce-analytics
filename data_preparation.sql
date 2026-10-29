-- ============================================================
-- Project: Brazilian E-Commerce Analytics (Olist)
-- File: data_preparation.sql
-- Purpose: Populate the typed working tables from the raw Olist
--          source tables.
--
-- Prerequisites:
--   1. The nine raw source tables must exist in the selected schema.
--   2. Run schema.sql first to create the working-table structure.
--   3. Select the intended target schema in MySQL Workbench before
--      executing this file.
--
-- Important:
--   This file performs INSERTs. Do not run it twice against the
--   same populated working tables, or rows may be duplicated or
--   primary-key errors may occur. For a clean rebuild, intentionally
--   rebuild the working-table structure with schema.sql first.
--
-- Transformations:
--   - Empty strings are converted to NULL where appropriate.
--   - Numeric fields are cast to numeric types.
--   - Timestamp text is converted to DATETIME.
--   - Raw source tables are not modified.
-- ============================================================

-- 1. Customers
INSERT INTO customers (
    customer_id,
    customer_unique_id,
    customer_zip_code_prefix,
    customer_city,
    customer_state
)
SELECT
    NULLIF(customer_id, ''),
    NULLIF(customer_unique_id, ''),
    NULLIF(customer_zip_code_prefix, ''),
    NULLIF(customer_city, ''),
    NULLIF(customer_state, '')
FROM olist_customers_dataset;


-- 2. Sellers
INSERT INTO sellers (
    seller_id,
    seller_zip_code_prefix,
    seller_city,
    seller_state
)
SELECT
    NULLIF(seller_id, ''),
    NULLIF(seller_zip_code_prefix, ''),
    NULLIF(seller_city, ''),
    NULLIF(seller_state, '')
FROM olist_sellers_dataset;


-- 3. Products
-- Note: The raw source uses the spellings 'lenght' in two column names.
INSERT INTO products (
    product_id,
    product_category_name,
    product_name_length,
    product_description_length,
    product_photos_qty,
    product_weight_g,
    product_length_cm,
    product_height_cm,
    product_width_cm
)
SELECT
    NULLIF(product_id, ''),
    NULLIF(product_category_name, ''),
    CAST(NULLIF(product_name_lenght, '') AS UNSIGNED),
    CAST(NULLIF(product_description_lenght, '') AS UNSIGNED),
    CAST(NULLIF(product_photos_qty, '') AS UNSIGNED),
    CAST(NULLIF(product_weight_g, '') AS UNSIGNED),
    CAST(NULLIF(product_length_cm, '') AS UNSIGNED),
    CAST(NULLIF(product_height_cm, '') AS UNSIGNED),
    CAST(NULLIF(product_width_cm, '') AS UNSIGNED)
FROM olist_products_dataset;


-- 4. Category translations
INSERT INTO category_translation (
    product_category_name,
    product_category_name_english
)
SELECT
    NULLIF(product_category_name, ''),
    NULLIF(product_category_name_english, '')
FROM product_category_name_translation;


-- 5. Orders
-- Parent customers must be populated before orders because of the FK.
INSERT INTO orders (
    order_id,
    customer_id,
    order_status,
    order_purchase_timestamp,
    order_approved_at,
    order_delivered_carrier_date,
    order_delivered_customer_date,
    order_estimated_delivery_date
)
SELECT
    NULLIF(order_id, ''),
    NULLIF(customer_id, ''),
    NULLIF(order_status, ''),
    STR_TO_DATE(NULLIF(order_purchase_timestamp, ''), '%Y-%m-%d %H:%i:%s'),
    STR_TO_DATE(NULLIF(order_approved_at, ''), '%Y-%m-%d %H:%i:%s'),
    STR_TO_DATE(NULLIF(order_delivered_carrier_date, ''), '%Y-%m-%d %H:%i:%s'),
    STR_TO_DATE(NULLIF(order_delivered_customer_date, ''), '%Y-%m-%d %H:%i:%s'),
    STR_TO_DATE(NULLIF(order_estimated_delivery_date, ''), '%Y-%m-%d %H:%i:%s')
FROM olist_orders_dataset;


-- 6. Order items
-- Orders, products, and sellers must be populated before order_items.
INSERT INTO order_items (
    order_id,
    order_item_id,
    product_id,
    seller_id,
    shipping_limit_date,
    price,
    freight_value
)
SELECT
    NULLIF(order_id, ''),
    CAST(NULLIF(order_item_id, '') AS UNSIGNED),
    NULLIF(product_id, ''),
    NULLIF(seller_id, ''),
    STR_TO_DATE(NULLIF(shipping_limit_date, ''), '%Y-%m-%d %H:%i:%s'),
    CAST(NULLIF(price, '') AS DECIMAL(10,2)),
    CAST(NULLIF(freight_value, '') AS DECIMAL(10,2))
FROM olist_order_items_dataset;


-- 7. Order payments
INSERT INTO order_payments (
    order_id,
    payment_sequential,
    payment_type,
    payment_installments,
    payment_value
)
SELECT
    NULLIF(order_id, ''),
    CAST(NULLIF(payment_sequential, '') AS UNSIGNED),
    NULLIF(payment_type, ''),
    CAST(NULLIF(payment_installments, '') AS UNSIGNED),
    CAST(NULLIF(payment_value, '') AS DECIMAL(10,2))
FROM olist_order_payments_dataset;


-- 8. Order reviews
-- A generated review_record_id is assigned automatically by the table.
INSERT INTO order_reviews (
    review_id,
    order_id,
    review_score,
    review_comment_title,
    review_comment_message,
    review_creation_date,
    review_answer_timestamp
)
SELECT
    NULLIF(review_id, ''),
    NULLIF(order_id, ''),
    CAST(NULLIF(review_score, '') AS UNSIGNED),
    NULLIF(review_comment_title, ''),
    NULLIF(review_comment_message, ''),
    STR_TO_DATE(NULLIF(review_creation_date, ''), '%Y-%m-%d %H:%i:%s'),
    STR_TO_DATE(NULLIF(review_answer_timestamp, ''), '%Y-%m-%d %H:%i:%s')
FROM olist_order_reviews_dataset;


-- 9. Geolocation
-- Large table: check the row count before retrying after any timeout.
INSERT INTO geolocation (
    geolocation_zip_code_prefix,
    geolocation_lat,
    geolocation_lng,
    geolocation_city,
    geolocation_state
)
SELECT
    NULLIF(geolocation_zip_code_prefix, ''),
    CAST(NULLIF(geolocation_lat, '') AS DECIMAL(12,8)),
    CAST(NULLIF(geolocation_lng, '') AS DECIMAL(12,8)),
    NULLIF(geolocation_city, ''),
    NULLIF(geolocation_state, '')
FROM olist_geolocation_dataset;


-- End of data preparation.
-- Suggested validation: compare working-table row counts with the
-- expected counts documented in the project README.
