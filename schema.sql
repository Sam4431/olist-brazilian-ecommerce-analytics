-- MySQL dump 10.13  Distrib 8.0.46, for Win64 (x86_64)
--
-- Host: 127.0.0.1    Database: brazilian_ecommerce
-- ------------------------------------------------------
-- Server version	8.0.46

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `category_translation`
--

DROP TABLE IF EXISTS `category_translation`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `category_translation` (
  `product_category_name` varchar(100) NOT NULL,
  `product_category_name_english` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`product_category_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `customers`
--

DROP TABLE IF EXISTS `customers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `customers` (
  `customer_id` varchar(32) NOT NULL,
  `customer_unique_id` varchar(32) NOT NULL,
  `customer_zip_code_prefix` char(5) DEFAULT NULL,
  `customer_city` varchar(100) DEFAULT NULL,
  `customer_state` char(2) DEFAULT NULL,
  PRIMARY KEY (`customer_id`),
  KEY `idx_customers_unique_id` (`customer_unique_id`),
  KEY `idx_customers_state` (`customer_state`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `geolocation`
--

DROP TABLE IF EXISTS `geolocation`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `geolocation` (
  `geolocation_record_id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `geolocation_zip_code_prefix` char(5) NOT NULL,
  `geolocation_lat` decimal(12,8) NOT NULL,
  `geolocation_lng` decimal(12,8) NOT NULL,
  `geolocation_city` varchar(100) DEFAULT NULL,
  `geolocation_state` char(2) DEFAULT NULL,
  PRIMARY KEY (`geolocation_record_id`),
  KEY `idx_geolocation_zip_prefix` (`geolocation_zip_code_prefix`)
) ENGINE=InnoDB AUTO_INCREMENT=1048561 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `order_items`
--

DROP TABLE IF EXISTS `order_items`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `order_items` (
  `order_id` varchar(32) NOT NULL,
  `order_item_id` int NOT NULL,
  `product_id` varchar(32) NOT NULL,
  `seller_id` varchar(32) NOT NULL,
  `shipping_limit_date` datetime DEFAULT NULL,
  `price` decimal(10,2) NOT NULL,
  `freight_value` decimal(10,2) NOT NULL,
  PRIMARY KEY (`order_id`,`order_item_id`),
  KEY `idx_order_items_product_id` (`product_id`),
  KEY `idx_order_items_seller_id` (`seller_id`),
  CONSTRAINT `fk_order_items_orders` FOREIGN KEY (`order_id`) REFERENCES `orders` (`order_id`),
  CONSTRAINT `fk_order_items_products` FOREIGN KEY (`product_id`) REFERENCES `products` (`product_id`),
  CONSTRAINT `fk_order_items_sellers` FOREIGN KEY (`seller_id`) REFERENCES `sellers` (`seller_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `order_payments`
--

DROP TABLE IF EXISTS `order_payments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `order_payments` (
  `order_id` varchar(32) NOT NULL,
  `payment_sequential` int NOT NULL,
  `payment_type` varchar(30) NOT NULL,
  `payment_installments` int NOT NULL,
  `payment_value` decimal(10,2) NOT NULL,
  PRIMARY KEY (`order_id`,`payment_sequential`),
  KEY `idx_order_payments_type` (`payment_type`),
  CONSTRAINT `fk_order_payments_orders` FOREIGN KEY (`order_id`) REFERENCES `orders` (`order_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `order_reviews`
--

DROP TABLE IF EXISTS `order_reviews`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `order_reviews` (
  `review_record_id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `review_id` varchar(32) DEFAULT NULL,
  `order_id` varchar(32) NOT NULL,
  `review_score` tinyint unsigned NOT NULL,
  `review_comment_title` text,
  `review_comment_message` text,
  `review_creation_date` datetime DEFAULT NULL,
  `review_answer_timestamp` datetime DEFAULT NULL,
  PRIMARY KEY (`review_record_id`),
  KEY `idx_order_reviews_order_id` (`order_id`),
  KEY `idx_order_reviews_score` (`review_score`),
  CONSTRAINT `fk_order_reviews_orders` FOREIGN KEY (`order_id`) REFERENCES `orders` (`order_id`),
  CONSTRAINT `chk_order_reviews_score` CHECK ((`review_score` between 1 and 5))
) ENGINE=InnoDB AUTO_INCREMENT=131071 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `orders`
--

DROP TABLE IF EXISTS `orders`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `orders` (
  `order_id` varchar(32) NOT NULL,
  `customer_id` varchar(32) NOT NULL,
  `order_status` varchar(20) NOT NULL,
  `order_purchase_timestamp` datetime NOT NULL,
  `order_approved_at` datetime DEFAULT NULL,
  `order_delivered_carrier_date` datetime DEFAULT NULL,
  `order_delivered_customer_date` datetime DEFAULT NULL,
  `order_estimated_delivery_date` datetime DEFAULT NULL,
  PRIMARY KEY (`order_id`),
  KEY `idx_orders_customer_id` (`customer_id`),
  KEY `idx_orders_purchase_timestamp` (`order_purchase_timestamp`),
  KEY `idx_orders_status` (`order_status`),
  CONSTRAINT `fk_orders_customers` FOREIGN KEY (`customer_id`) REFERENCES `customers` (`customer_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `products`
--

DROP TABLE IF EXISTS `products`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `products` (
  `product_id` varchar(32) NOT NULL,
  `product_category_name` varchar(100) DEFAULT NULL,
  `product_name_length` int DEFAULT NULL,
  `product_description_length` int DEFAULT NULL,
  `product_photos_qty` int DEFAULT NULL,
  `product_weight_g` int DEFAULT NULL,
  `product_length_cm` int DEFAULT NULL,
  `product_height_cm` int DEFAULT NULL,
  `product_width_cm` int DEFAULT NULL,
  PRIMARY KEY (`product_id`),
  KEY `idx_products_category` (`product_category_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `sellers`
--

DROP TABLE IF EXISTS `sellers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sellers` (
  `seller_id` varchar(32) NOT NULL,
  `seller_zip_code_prefix` char(5) DEFAULT NULL,
  `seller_city` varchar(100) DEFAULT NULL,
  `seller_state` char(2) DEFAULT NULL,
  PRIMARY KEY (`seller_id`),
  KEY `idx_sellers_state` (`seller_state`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-10-29  0:15:07
