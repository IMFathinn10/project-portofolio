SELECT * FROM order_detail
WHERE EXTRACT(YEAR FROM order_date) = 2021 AND is_valid = 1
ORDER BY after_discount DESC
LIMIT 10;

-- 1. FIND WHAT MONTH WITH THE BIGGEST TOTAL TRANSCATION VALUE (AFTER DISCOUNT) IN 2021--
SELECT 
    EXTRACT(MONTH FROM order_date) AS max_transaction_month,
    SUM(after_discount) AS biggest_transaction_value
FROM 
    order_detail
WHERE 
    EXTRACT(YEAR FROM order_date) = 2021 AND is_valid = 1
GROUP BY 
    EXTRACT(MONTH FROM order_date)
ORDER BY 
    biggest_transaction_value DESC
LIMIT 1
;

-- 2. FIND WHAT CATEGORY GENERATE THE MOST TRANSACTION VALUE IN 2022 --
SELECT
	s.category, SUM(o.after_discount) as total_transaction
FROM order_detail o
JOIN sku_detail s
	ON o.sku_id = s.id
WHERE EXTRACT(YEAR FROM o.order_date) = 2022 AND o.is_valid = 1
GROUP BY s.category
ORDER BY total_transaction DESC
LIMIT 3
;

-- 3. Compare the transaction value of each category in 2021 with 2022. 
-- Mention what categories have experienced an increase and what categories have experienced an increase
-- decrease in transaction value from 2021 to 2022.

WITH transaction2021 AS (	
	SELECT
		s.category,
        EXTRACT(YEAR FROM o.order_date) AS transaction_year,
        SUM(o.after_discount) AS total_transaction_value
    FROM
    order_detail o
	JOIN sku_detail s
		ON o.sku_id = s.id
    WHERE
        EXTRACT(YEAR FROM o.order_date) = 2021 AND o.is_valid = 1
    GROUP BY
        s.category, EXTRACT(YEAR FROM o.order_date)
	ORDER BY transaction_year ASC, total_transaction_value DESC
	),
	transaction2022 AS (
	SELECT
		s.category,
		EXTRACT(YEAR FROM o.order_date) AS transaction_year,
        SUM(o.after_discount) AS total_transaction_value
    FROM
    order_detail o
	JOIN sku_detail s
		ON o.sku_id = s.id
    WHERE
        EXTRACT(YEAR FROM o.order_date) = 2022 AND o.is_valid = 1
    GROUP BY
        s.category, EXTRACT(YEAR FROM o.order_date)
	ORDER BY transaction_year ASC, total_transaction_value DESC
	)
	
SELECT
	t1.category, 
	CASE
		WHEN t2.total_transaction_value > t1.total_transaction_value THEN 'Increase'
		WHEN t2.total_transaction_value < t1.total_transaction_value THEN 'Decrease'
		ELSE 'No Change'
	END AS transaction_change,
	ROUND((t2.total_transaction_value - t1.total_transaction_value)::numeric, 2) AS difference
FROM transaction2021 t1
JOIN transaction2022 t2
	ON t2.category = t1.category
GROUP BY t1.category, transaction_change, difference
;

-- 4. Show the top 5 most popular payment methods used during 2022
-- (based on total unique orders).

SELECT
	p.payment_method, COUNT(o.payment_id) as payment_count, SUM(o.qty_ordered) AS total_qty_ordered
FROM order_detail o
JOIN payment_detail p
	ON o.payment_id = p.id
WHERE EXTRACT(YEAR FROM o.order_date) = 2022 AND o.is_valid = 1
GROUP BY p.payment_method
ORDER BY payment_count DESC
LIMIT 5
;

-- 5. Transaction value on this group of product (Samsung, Apple, Sony, Huawei, Lenovo)

WITH gadget_transaction AS (
SELECT
	o.sku_id AS product_id, 
	s.sku_name AS product_name, 
	o.qty_ordered AS total_ordered, 
	o.after_discount AS total_transaction,
	CASE
		WHEN s.sku_name LIKE '%Samsung%' THEN 'Samsung'
		WHEN s.sku_name LIKE '%Apple%' THEN 'Apple'
		WHEN s.sku_name LIKE '%Sony%' THEN 'Sony'
		WHEN s.sku_name LIKE '%Huawei%' THEN 'Huawei'
		WHEN s.sku_name LIKE '%Lenovo%' THEN 'Lenovo'
	END AS product_group
FROM order_detail o
JOIN sku_detail s
	ON o.sku_id = s.id
WHERE (s.sku_name LIKE '%Samsung%'
	   OR s.sku_name LIKE '%Apple%'
	   OR s.sku_name LIKE '%Sony%'
	   OR s.sku_name LIKE '%Huawei%'
	   OR s.sku_name LIKE '%Lenovo%')
	   AND o.is_valid = 1
)

SELECT 
	product_group, 
	SUM(total_ordered) AS total_ordered,
	SUM(total_transaction) AS total_transaction
FROM gadget_transaction
GROUP BY product_group
ORDER BY total_transaction DESC
;


