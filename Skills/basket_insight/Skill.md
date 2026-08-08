# Skill: Basket Insight

## Name
basket_insight

## Description
Identifies products that are frequently bought together within the same
invoice. Surfaces cross-sell and upsell opportunities by finding the
strongest product pairings across all transactions.

## Trigger
Use this skill when the user asks about:
- Frequently bought together products
- Cross-sell or upsell opportunities
- Basket analysis or market basket
- Product combinations or pairings
- What to recommend alongside a product

## Input Parameters
- `country`: Filter to a specific country. Default: all countries
- `min_support`: Minimum number of times a pair appears. Default: 10
- `top_n`: Number of top pairs to return. Default: 20

## Logic
```sql
WITH invoice_products AS (
    SELECT
        t.INVOICE_NO,
        t.STOCK_CODE,
        p.DESCRIPTION,
        t.COUNTRY
    FROM HOL_ONLINE_RETAIL.DATA.FACT_TRANSACTIONS t
    JOIN HOL_ONLINE_RETAIL.DATA.DIM_PRODUCT p
      ON t.STOCK_CODE = p.STOCK_CODE
    WHERE t.IS_CANCELLATION = FALSE
      AND t.CUSTOMER_ID IS NOT NULL
),
product_pairs AS (
    SELECT
        a.STOCK_CODE        AS product_a_code,
        a.DESCRIPTION       AS product_a,
        b.STOCK_CODE        AS product_b_code,
        b.DESCRIPTION       AS product_b,
        COUNT(*)            AS pair_count
    FROM invoice_products a
    JOIN invoice_products b
      ON a.INVOICE_NO = b.INVOICE_NO
     AND a.STOCK_CODE < b.STOCK_CODE
    GROUP BY 1, 2, 3, 4
    HAVING COUNT(*) >= 10
)
SELECT
    product_a,
    product_b,
    pair_count,
    ROUND(pair_count * 100.0 / 
          (SELECT COUNT(DISTINCT INVOICE_NO) 
           FROM HOL_ONLINE_RETAIL.DATA.FACT_TRANSACTIONS 
           WHERE IS_CANCELLATION = FALSE), 4) AS support_pct
FROM product_pairs
ORDER BY pair_count DESC
LIMIT 20;
```

## Output
Returns top product pairs with:
- Product A and Product B names
- How many times bought together
- Support percentage across all invoices