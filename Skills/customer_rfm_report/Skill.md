# Skill: Customer RFM Report

## Name
customer_rfm_report

## Description
Generates a Recency-Frequency-Monetary (RFM) segmentation report for
customers. Segments customers into: Champions, Loyal, At Risk, and Lost.
Helps identify your most valuable and most at-risk customers.

## Trigger
Use this skill when the user asks about:
- Customer segments or customer value
- Best customers or loyal customers
- RFM analysis or customer scoring
- Which customers to target for marketing

## Input Parameters
- `country`: Filter to a specific country. Default: all countries
- `top_n`: Number of top customers to return. Default: 20

## Logic
```sql
WITH max_date AS (
    SELECT MAX(INVOICE_DATE) AS last_date
    FROM HOL_ONLINE_RETAIL.DATA.FACT_TRANSACTIONS
    WHERE IS_CANCELLATION = FALSE
),
rfm_base AS (
    SELECT
        t.CUSTOMER_ID,
        c.COUNTRY,
        DATEDIFF('day', MAX(t.INVOICE_DATE), 
                 (SELECT last_date FROM max_date)) AS recency,
        COUNT(DISTINCT t.INVOICE_NO)               AS frequency,
        ROUND(SUM(t.REVENUE), 2)                   AS monetary
    FROM HOL_ONLINE_RETAIL.DATA.FACT_TRANSACTIONS t
    JOIN HOL_ONLINE_RETAIL.DATA.DIM_CUSTOMER c
      ON t.CUSTOMER_ID = c.CUSTOMER_ID
    WHERE t.IS_CANCELLATION = FALSE
      AND t.CUSTOMER_ID IS NOT NULL
    GROUP BY t.CUSTOMER_ID, c.COUNTRY
),
rfm_scored AS (
    SELECT *,
        NTILE(4) OVER (ORDER BY recency ASC)   AS r_score,
        NTILE(4) OVER (ORDER BY frequency DESC) AS f_score,
        NTILE(4) OVER (ORDER BY monetary DESC)  AS m_score
    FROM rfm_base
),
rfm_segmented AS (
    SELECT *,
        r_score + f_score + m_score AS rfm_total,
        CASE
            WHEN r_score = 4 AND f_score = 4 THEN 'Champion'
            WHEN r_score >= 3 AND f_score >= 3 THEN 'Loyal'
            WHEN r_score >= 2 AND f_score >= 2 THEN 'At Risk'
            ELSE 'Lost'
        END AS segment
    FROM rfm_scored
)
SELECT
    CUSTOMER_ID,
    COUNTRY,
    recency     AS days_since_last_purchase,
    frequency   AS total_orders,
    monetary    AS total_revenue_gbp,
    segment,
    rfm_total   AS rfm_score
FROM rfm_segmented
ORDER BY monetary DESC
LIMIT 20;
```

## Output
Returns customer segments with:
- Customer ID and country
- Recency, frequency, monetary values
- RFM score and segment label