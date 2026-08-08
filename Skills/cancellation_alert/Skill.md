# Skill: Cancellation Alert

## Name
cancellation_alert

## Description
Detects products or countries with abnormally high cancellation rates
compared to their historical average. Uses z-score analysis over a
30-day rolling window to surface unusual spikes in cancellations.

## Trigger
Use this skill when the user asks about:
- Cancellations, returns, or refunds
- Unusual order patterns
- Anomalies in transactions
- Which products or countries have high return rates

## Input Parameters
- `group_by`: What to group analysis by. Options: "country", "product", "both"
- `threshold`: Z-score threshold to flag as anomaly. Default: 2.0

## Logic
```sql
WITH daily_cancellations AS (
    SELECT
        DATE_TRUNC('day', INVOICE_DATE)     AS txn_day,
        COUNTRY,
        STOCK_CODE,
        COUNT(CASE WHEN IS_CANCELLATION = TRUE 
              THEN 1 END)                   AS cancel_count,
        COUNT(*)                            AS total_count,
        ROUND(
            COUNT(CASE WHEN IS_CANCELLATION = TRUE THEN 1 END) 
            / NULLIF(COUNT(*), 0) * 100, 2) AS cancel_rate
    FROM HOL_ONLINE_RETAIL.DATA.FACT_TRANSACTIONS
    GROUP BY 1, 2, 3
),
stats AS (
    SELECT
        COUNTRY,
        STOCK_CODE,
        AVG(cancel_rate)    AS avg_rate,
        STDDEV(cancel_rate) AS std_rate
    FROM daily_cancellations
    GROUP BY 1, 2
),
anomalies AS (
    SELECT
        d.txn_day,
        d.COUNTRY,
        d.STOCK_CODE,
        d.cancel_rate,
        s.avg_rate,
        ROUND((d.cancel_rate - s.avg_rate) 
              / NULLIF(s.std_rate, 0), 2) AS z_score
    FROM daily_cancellations d
    JOIN stats s 
      ON d.COUNTRY = s.COUNTRY 
     AND d.STOCK_CODE = s.STOCK_CODE
)
SELECT *
FROM anomalies
WHERE ABS(z_score) > 2.0
ORDER BY ABS(z_score) DESC
LIMIT 20;
```

## Output
Returns a table of flagged anomalies with:
- Date, country, product
- Cancellation rate
- Z-score (how unusual it is)
- Historical average rate