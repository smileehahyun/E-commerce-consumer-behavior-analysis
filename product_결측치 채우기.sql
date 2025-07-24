-- Product 테이블 데이터 뜯어보기, 결측치 확인하기
/*
product_id, gender, masterCategory, articleType, 
baseColour, season, year,usage, productDisplayName
*/

SELECT *
FROM  product;

TRUNCATE TABLE product;
LOAD DATA LOCAL INFILE '/Users/hapresent/Desktop/데이터톤/archive/product_nullfix.csv'
INTO TABLE product
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;


-- 컬럼별 결측치 개수 확인하기
SELECT
 COUNT(*) AS total_rows ,
 COUNT(*) - COUNT(product_id) as null_product_id,
 COUNT(*) - COUNT(gender) as null_gender,
 COUNT(*) - COUNT(masterCategory) as null_masterCategory,
 COUNT(*) - COUNT(articleType) as null_articleType,
 COUNT(*) - COUNT(baseColour) as null_baseColour,
 COUNT(*) - COUNT(season) as null_season,
 COUNT(*) - COUNT(year) as null_year,
 COUNT(*) - COUNT(`usage`) as null_usage,
 COUNT(*) - COUNT(productDisplayName) as null_productDisplayName 
FROM product ; 

-- null_baseColour(15), null_season(21), null_year(1), null_usage(317), null_productDisplayName(7)
-- fill missing--
SET SQL_SAFE_UPDATES = 0;

UPDATE product
SET baseColour = 'Black'
WHERE baseColour IS NULL;

UPDATE product
SET season = 'Summer'
WHERE season IS NULL;

UPDATE product
SET year = '2012'
WHERE year IS NULL;

UPDATE product
SET `usage` = 'Casual'
WHERE `usage` IS NULL; 

UPDATE product
SET productDisplayName = 'Lucera Women Silver Earrings'
WHERE productDisplayName IS NULL;


SELECT * 
FROM product;
