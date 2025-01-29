
--  RFM (Recency, Frequency, Monetary) Segmentation
WITH rfm AS (
    SELECT 
        user_id,
        RANK() OVER (ORDER BY MAX(purchase_frequency) DESC) AS recency_rank,
        RANK() OVER (ORDER BY SUM(purchase_frequency) DESC) AS frequency_rank,
        RANK() OVER (ORDER BY SUM(purchase_amount) DESC) AS monetary_rank
    FROM customer_purchasing_behaviors
    GROUP BY user_id
)
SELECT 
    user_id,
    recency_rank,
    frequency_rank,
    monetary_rank,
    (recency_rank + frequency_rank + monetary_rank) AS rfm_score
FROM rfm
ORDER BY rfm_score ASC;

--  Customer Lifetime Value Prediction
SELECT 
    user_id,
    (purchase_frequency * AVG(purchase_amount)) AS estimated_lifetime_value
FROM customer_purchasing_behaviors
GROUP BY user_id
ORDER BY estimated_lifetime_value DESC
LIMIT 10;

--  Detect Anomalous Purchasing Behavior
WITH regional_avg AS (
    SELECT 
        region, 
        AVG(purchase_amount) AS avg_purchase_amount
    FROM customer_purchasing_behaviors
    GROUP BY region
)
SELECT 
    c.user_id,
    c.region,
    c.purchase_amount,
    r.avg_purchase_amount,
    (c.purchase_amount - r.avg_purchase_amount) AS difference
FROM customer_purchasing_behaviors c
JOIN regional_avg r ON c.region = r.region
WHERE c.purchase_amount > r.avg_purchase_amount * 1.5
ORDER BY difference DESC;

--  KPI Dashboard Query
SELECT 
    region,
    SUM(purchase_amount) AS total_sales,
    AVG(loyalty_score) AS avg_loyalty_score,
    MAX(purchase_amount) AS top_spender,
    COUNT(user_id) AS total_customers
FROM customer_purchasing_behaviors
GROUP BY region
ORDER BY total_sales DESC;

--  Customer Churn Risk
WITH loyalty_decline AS (
    SELECT 
        user_id,
        loyalty_score,
        purchase_frequency,
        LAG(purchase_frequency) OVER (PARTITION BY user_id ORDER BY purchase_frequency DESC) AS prev_frequency
    FROM customer_purchasing_behaviors
)
SELECT 
    user_id,
    loyalty_score,
    purchase_frequency,
    prev_frequency,
    (prev_frequency - purchase_frequency) AS frequency_drop
FROM loyalty_decline
WHERE loyalty_score < 4.0 AND (prev_frequency - purchase_frequency) > 2;

--  Predicting High-Loyalty Customers
SELECT 
    region,
    AVG(age) AS avg_age,
    AVG(annual_income) AS avg_income,
    AVG(purchase_frequency) AS avg_frequency
FROM customer_purchasing_behaviors
WHERE loyalty_score > 8
GROUP BY region
ORDER BY avg_income DESC;

--  Customer Clustering
WITH normalized_data AS (
    SELECT 
        user_id,
        (annual_income - AVG(annual_income) OVER()) / STDDEV(annual_income) OVER() AS income_zscore,
        (purchase_amount - AVG(purchase_amount) OVER()) / STDDEV(purchase_amount) OVER() AS purchase_zscore
    FROM customer_purchasing_behaviors
)
SELECT 
    user_id,
    income_zscore,
    purchase_zscore,
    CASE
        WHEN income_zscore > 1 AND purchase_zscore > 1 THEN 'High Income, High Spending'
        WHEN income_zscore > 1 THEN 'High Income, Low Spending'
        WHEN purchase_zscore > 1 THEN 'Low Income, High Spending'
        ELSE 'Low Income, Low Spending'
    END AS cluster
FROM normalized_data;

--  Seasonality in Purchases
SELECT 
    DATE_FORMAT(purchase_date, '%Y-%m') AS month,
    SUM(purchase_frequency) AS total_purchases
FROM customer_purchasing_behaviors
GROUP BY month
ORDER BY month;
