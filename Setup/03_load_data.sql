USE ROLE ACCOUNTADMIN;
USE WAREHOUSE RETAIL_HOL_WH;
USE DATABASE HOL_ONLINE_RETAIL;
USE SCHEMA DATA;

-- ============================================================
-- STEP 1: Load a staging table with raw data from both files
-- ============================================================

CREATE OR REPLACE TEMPORARY TABLE RAW_RETAIL (
  INVOICE_NO    VARCHAR(20),
  STOCK_CODE    VARCHAR(20),
  DESCRIPTION   VARCHAR(500),
  QUANTITY      INTEGER,
  INVOICE_DATE  TIMESTAMP,
  UNIT_PRICE    FLOAT,
  CUSTOMER_ID   VARCHAR(20),
  COUNTRY       VARCHAR(100)
);

COPY INTO RAW_RETAIL
FROM @RETAIL_DATA_STAGE
FILE_FORMAT = RETAIL_CSV_FORMAT
ON_ERROR = 'CONTINUE';

-- ============================================================
-- STEP 2: Populate DIM_COUNTRY
-- ============================================================

INSERT INTO DATA.DIM_COUNTRY (COUNTRY, REGION)
SELECT DISTINCT
  COUNTRY,
  CASE
    WHEN COUNTRY IN ('United Kingdom', 'France', 'Germany', 'Spain',
                     'Netherlands', 'Belgium', 'Switzerland', 'Portugal',
                     'Italy', 'Norway', 'Denmark', 'Sweden', 'Finland',
                     'Austria', 'Greece', 'Iceland', 'Cyprus', 'Malta',
                     'Poland', 'Czech Republic', 'Lithuania') 
         THEN 'Europe'
    WHEN COUNTRY IN ('USA', 'Canada') 
         THEN 'North America'
    WHEN COUNTRY IN ('Australia', 'New Zealand') 
         THEN 'Oceania'
    WHEN COUNTRY IN ('Japan', 'Singapore', 'Hong Kong', 'Bahrain',
                     'Saudi Arabia', 'Lebanon', 'UAE', 'Israel') 
         THEN 'Asia & Middle East'
    WHEN COUNTRY IN ('Brazil') 
         THEN 'South America'
    WHEN COUNTRY IN ('Nigeria', 'South Africa', 'RSA') 
         THEN 'Africa'
    ELSE 'Other'
  END AS REGION
FROM RAW_RETAIL
WHERE COUNTRY IS NOT NULL;

-- ============================================================
-- STEP 3: Populate DIM_PRODUCT
-- ============================================================

INSERT INTO DATA.DIM_PRODUCT (STOCK_CODE, DESCRIPTION)
SELECT DISTINCT
  STOCK_CODE,
  MAX(DESCRIPTION) AS DESCRIPTION
FROM RAW_RETAIL
WHERE STOCK_CODE IS NOT NULL
GROUP BY STOCK_CODE;

-- ============================================================
-- STEP 4: Populate DIM_CUSTOMER
-- ============================================================

INSERT INTO DATA.DIM_CUSTOMER (CUSTOMER_ID, COUNTRY)
SELECT DISTINCT
  CUSTOMER_ID,
  MAX(COUNTRY) AS COUNTRY
FROM RAW_RETAIL
WHERE CUSTOMER_ID IS NOT NULL
GROUP BY CUSTOMER_ID;

-- ============================================================
-- STEP 5: Populate FACT_TRANSACTIONS
-- ============================================================

INSERT INTO DATA.FACT_TRANSACTIONS (
  TRANSACTION_ID,
  INVOICE_NO,
  STOCK_CODE,
  CUSTOMER_ID,
  COUNTRY,
  INVOICE_DATE,
  QUANTITY,
  UNIT_PRICE,
  REVENUE,
  IS_CANCELLATION
)
SELECT
  INVOICE_NO || '-' || STOCK_CODE || '-' || 
    ROW_NUMBER() OVER (PARTITION BY INVOICE_NO, STOCK_CODE ORDER BY INVOICE_DATE) 
    AS TRANSACTION_ID,
  INVOICE_NO,
  STOCK_CODE,
  CUSTOMER_ID,
  COUNTRY,
  INVOICE_DATE,
  QUANTITY,
  UNIT_PRICE,
  QUANTITY * UNIT_PRICE          AS REVENUE,
  LEFT(INVOICE_NO, 1) = 'C'     AS IS_CANCELLATION
FROM RAW_RETAIL
WHERE STOCK_CODE IS NOT NULL
  AND QUANTITY > 0
  AND UNIT_PRICE > 0;

-- ============================================================
-- STEP 6: Verify row counts
-- ============================================================

SELECT 'DIM_COUNTRY'      AS TABLE_NAME, COUNT(*) AS ROW_COUNT FROM DATA.DIM_COUNTRY
UNION ALL
SELECT 'DIM_PRODUCT'      AS TABLE_NAME, COUNT(*) AS ROW_COUNT FROM DATA.DIM_PRODUCT
UNION ALL
SELECT 'DIM_CUSTOMER'     AS TABLE_NAME, COUNT(*) AS ROW_COUNT FROM DATA.DIM_CUSTOMER
UNION ALL
SELECT 'FACT_TRANSACTIONS' AS TABLE_NAME, COUNT(*) AS ROW_COUNT FROM DATA.FACT_TRANSACTIONS;