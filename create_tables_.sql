CREATE DATABASE IF NOT EXISTS ecommerce_db;
USE ecommerce_db;


SHOW VARIABLES LIKE 'local_infile';
SET GLOBAL local_infile = 1;


-- if exists 
drop table IF EXISTS click_stream;
drop table IF EXISTS Customer;
drop table IF EXISTS product;
drop table IF EXISTS transactions;

drop view IF EXISTS view_click_stream_add_promo;
drop view IF EXISTS view_click_stream_add_to_cart;
drop view IF EXISTS view_click_stream_booking;
drop view IF EXISTS view_click_stream_search;


-- click_stream setting
CREATE TABLE click_stream (
    session_id VARCHAR(100),
    event_name VARCHAR(50),
    event_time DATETIME(6),
    event_id VARCHAR(100),
    traffic_source VARCHAR(50),
    event_metadata TEXT
);

LOAD DATA LOCAL INFILE '/Users/hapresent/Desktop/데이터톤/archive/click_stream.csv' 
INTO TABLE click_stream
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"' 
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(session_id, event_name, event_time, event_id, traffic_source, event_metadata);

CREATE OR REPLACE VIEW view_click_stream_add_to_cart AS
SELECT
    session_id,
    event_name,
    event_time,
    event_id,
    traffic_source,
    event_metadata,

    -- product_id
    CASE
        WHEN event_name = 'ADD_TO_CART' THEN
            REPLACE(
                TRIM(BOTH '\'' FROM
                    SUBSTRING_INDEX(SUBSTRING_INDEX(event_metadata, 'product_id', -1), ',', 1)
                ),
                ': ',
                ''
            )
    END AS product_id,

    -- quantity
    CASE
        WHEN event_name = 'ADD_TO_CART' THEN
            REPLACE(
                TRIM(BOTH '\'' FROM
                    SUBSTRING_INDEX(SUBSTRING_INDEX(event_metadata, 'quantity', -1), ',', 1)
                ),
                ': ',
                ''
            )
    END AS quantity,

    -- item_price
    CASE
        WHEN event_name = 'ADD_TO_CART' THEN
            REPLACE(
                TRIM(BOTH '\'' FROM
                    SUBSTRING_INDEX(SUBSTRING_INDEX(event_metadata, 'item_price', -1), '}', 1)
                ),
                ': ',
                ''
            )
    END AS item_price
FROM click_stream
WHERE event_name = 'ADD_TO_CART';

CREATE OR REPLACE VIEW view_click_stream_booking AS
SELECT
    session_id,
    event_name,
    event_time,
    event_id,
    traffic_source,
    event_metadata,

    CASE
        WHEN event_name = 'BOOKING' THEN
            TRIM(BOTH '\'' FROM
                REPLACE(
                    SUBSTRING_INDEX(SUBSTRING_INDEX(event_metadata, 'payment_status', -1), '}', 1),
                    ': ',
                    ''
                )
            )
        ELSE NULL
    END AS payment_status
FROM click_stream
WHERE event_name = 'BOOKING';

CREATE OR REPLACE VIEW view_click_stream_search AS
SELECT
    session_id,
    event_name,
    event_time,
    event_id,
    traffic_source,
    event_metadata,
    
    CASE
        WHEN event_name = 'SEARCH' THEN
            TRIM(BOTH '\'' FROM
                REPLACE(
                    SUBSTRING_INDEX(SUBSTRING_INDEX(event_metadata, 'search_keywords', -1), '}', 1),
                    ': ',
                    ''
                )
            )
        ELSE NULL
    END AS search_keywords
FROM click_stream
WHERE event_name = 'SEARCH';

CREATE OR REPLACE VIEW view_click_stream_add_promo AS
SELECT
    session_id,
    event_name,
    event_time,
    event_id,
    traffic_source,
    event_metadata,

    CASE
        WHEN event_name = 'ADD_PROMO' THEN
            TRIM(BOTH '\'' FROM
                REPLACE(
                    SUBSTRING_INDEX(SUBSTRING_INDEX(event_metadata, 'promo_code', -1), ',', 1),
                    ': ',
                    ''
                )
            )
        ELSE NULL
    END AS promo_code,

    CASE
        WHEN event_name = 'ADD_PROMO' THEN
            TRIM(BOTH '\'' FROM
                TRIM(BOTH '}' FROM
                    REPLACE(
                        SUBSTRING_INDEX(event_metadata, 'promo_amount', -1),
                        ': ',
                        ''
                    )
                )
            )
        ELSE NULL
    END AS promo_amount
FROM click_stream
WHERE event_name = 'ADD_PROMO';

-- transactions setting
CREATE TABLE transactions (
    created_at DATETIME,
    customer_id INT,
    booking_id VARCHAR(50),
    session_id VARCHAR(50),
    product_metadata TEXT,
    payment_method VARCHAR(30),
    payment_status VARCHAR(20),
    promo_amount INT,
    promo_code VARCHAR(50),
    shipment_fee INT,
    shipment_date_limit DATETIME,
    shipment_location_lat DOUBLE,
    shipment_location_long DOUBLE,
    total_amount INT
);

LOAD DATA LOCAL INFILE  '/Users/hapresent/Desktop/데이터톤/archive/transactions.csv'
INTO TABLE transactions
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"' 
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;


CREATE TABLE order_items (
  booking_id VARCHAR(100),
  product_id INT,
  quantity INT,
  item_price INT
);

LOAD DATA LOCAL INFILE '/Users/hapresent/Desktop/데이터톤/archive/order_items.csv'
INTO TABLE order_items
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"' 
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- product setting
CREATE TABLE product (
product_id INT,
gender VARCHAR(10),
masterCategory VARCHAR(50),
subCategory VARCHAR(50),
articleType VARCHAR(50),
baseColour VARCHAR(30),
season VARCHAR(10),
year INT,
`usage` VARCHAR(20),  #usage는 sql에서 단어로 인식x, ``로 감싸줌
productDisplayName VARCHAR(100)
);

LOAD DATA LOCAL INFILE '/Users/hapresent/Desktop/데이터톤/archive/nullfix_product.csv'
INTO TABLE product
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"' 
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- customer setting
CREATE TABLE Customer (
customer_id INT PRIMARY KEY,
first_name VARCHAR(100),
last_name VARCHAR(100),
username VARCHAR(100),
email VARCHAR(100),
gender ENUM('M', 'F') DEFAULT 'F',
birthdate DATE,
device_type VARCHAR(100),
device_id VARCHAR(100),
device_version VARCHAR(100),
home_location_lat DECIMAL(22,20),
home_location_long DECIMAL(18,15),
home_location VARCHAR(100),
home_country VARCHAR(100),
first_join_date DATE
);

LOAD DATA LOCAL INFILE '/Users/hapresent/Desktop/데이터톤/archive/customer.csv'
INTO TABLE Customer
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"' 
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

ALTER TABLE transactions
DROP COLUMN product_metadata;
