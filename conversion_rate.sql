--  장바구니 -> 구매 전환율 분석하기. 

-- Step1. 장바구니에 담은 제품의 수 파악하기 (큰 흐름)
SELECT DISTINCT 
	session_id, event_name, event_time, event_id, traffic_source, product_id, quantity, item_price
FROM view_click_stream_add_to_cart ;

SELECT sum(quantity) as total_add_to_cart
FROM view_click_stream_add_to_cart ; -- 2789206가지 

-- Step2. 실제로 거래가 이루어진 제품의 수 파악하기 
SELECT SUM(o.quantity) AS total_purchased_quantity
FROM order_items o
JOIN transactions t ON o.booking_id = t.booking_id
WHERE t.payment_status = 'Success'; -- 1772409 

-- Step3. 전환율 계산 
WITH 
cart_total AS (
  SELECT SUM(quantity) AS total_add_to_cart
  FROM view_click_stream_add_to_cart
),
purchase_total AS (
  SELECT SUM(o.quantity) AS total_purchased_quantity
  FROM order_items o
  JOIN transactions t ON o.booking_id = t.booking_id
  WHERE t.payment_status = 'Success'
)
SELECT
  ROUND(p.total_purchased_quantity / c.total_add_to_cart * 100, 2) AS conversion_rate_percent
FROM cart_total c, purchase_total p; 
