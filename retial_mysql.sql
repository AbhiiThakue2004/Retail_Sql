-- RETAIL DATA CLEANING PROJECT

-- 1. CREATE DATABASE

CREATE DATABASE retail;
USE retail;
SELECT * 
FROM retail;

-- =====================================================
-- 2. CREATED BACKUP / WORKING TABLE
-- =====================================================

CREATE TABLE retail_2
LIKE retail;

INSERT INTO retail_2
SELECT *
FROM retail;

SELECT *
FROM retail_2;


-- =====================================================
-- 3. CHECK FOR DUPLICATES
-- =====================================================

SELECT *,
ROW_NUMBER() OVER (
    PARTITION BY 
        `Transaction ID`,
        `Customer ID`,
        `Category`,
        `Item`,
        `Price Per Unit`,
        `Quantity`,
        `Total Spent`,
        `Payment Method`,
        `Location`,
        `Transaction Date`,
        `Discount Applied`
) AS row_number
FROM retail_2;


-- =====================================================
-- 4. FIND DUPLICATE RECORDS USING CTE
-- =====================================================

WITH duplicate_cte AS
(
    SELECT *,
    ROW_NUMBER() OVER (
        PARTITION BY 
            `Transaction ID`,
            `Customer ID`,
            `Category`,
            `Item`,
            `Price Per Unit`,
            `Quantity`,
            `Total Spent`,
            `Payment Method`,
            `Location`,
            `Transaction Date`,
            `Discount Applied`
    ) AS row_number
    FROM retail_2
)

SELECT *
FROM duplicate_cte
WHERE row_number > 1;

-- No duplicates found


-- =====================================================
-- 5. STANDARDIZING DATA
-- =====================================================

-- Checking Transaction Date format

SELECT 
    `Transaction Date`,
    STR_TO_DATE(`Transaction Date`, '%Y-%m-%d')
FROM retail_2;


-- =====================================================
-- 6. CONVERTED TRANSACTION DATE TO DATE FORMAT
-- =====================================================

UPDATE retail_2
SET `Transaction Date` = STR_TO_DATE(`Transaction Date`, '%Y-%m-%d');

ALTER TABLE retail_2
MODIFY `Transaction Date` DATE;


-- =====================================================
-- 7. CLEAN CATEGORY COLUMN
-- =====================================================

SELECT DISTINCT `Category`
FROM retail_2;

-- Checking inconsistent category names
SELECT DISTINCT `Category`
FROM retail_2
WHERE `Category` LIKE '%elect%';


-- Fixing category names

UPDATE retail_2
SET `Category` = 'Electronic household essentials'
WHERE `Category` = 'electric household essentials';


UPDATE retail_2
SET `Category` = 'Computers and electronic accessories'
WHERE `Category` = 'Computers and electric accessories';


-- =====================================================
-- 8. CHECKING NULL / ZERO VALUES
-- =====================================================

SELECT COUNT(*)
FROM retail_2
WHERE `Price Per Unit` = 0;


SELECT COUNT(*)
FROM retail_2
WHERE `Quantity` = 0;


SELECT COUNT(*)
FROM retail_2
WHERE `Total Spent` = 0;


-- =====================================================
-- 9. FIXING ZERO VALUES
-- =====================================================

-- Updating Quantity

UPDATE retail_2
SET `Quantity` = 1
WHERE `Quantity` = 0;


-- Updating Total Spent

UPDATE retail_2
SET `Total Spent` = (`Price Per Unit` * `Quantity`)
WHERE `Total Spent` = 0;


-- Updating Price Per Unit

UPDATE retail_2
SET `Price Per Unit` = (`Total Spent` / `Quantity`)
WHERE `Price Per Unit` = 0;


-- =====================================================
-- 10. CHECKING NULL / BLANK ITEM VALUES
-- =====================================================

SELECT
    COUNT(*) AS total_rows,
    SUM(`Item` IS NULL) AS null_items,
    SUM(`Item` = '') AS blank_items
FROM retail_2;


-- =====================================================
-- 11. FILLING BLANK ITEM VALUES
-- =====================================================

UPDATE retail_2 t1
JOIN retail_2 t2
    ON t1.Category = t2.Category
    AND t1.`Price Per Unit` = t2.`Price Per Unit`

SET t1.Item = t2.Item

WHERE t1.Item = ''
AND t2.Item <> ''
AND t1.`Transaction ID` IS NOT NULL;


-- =====================================================
-- 12. CHECKING DISCOUNT APPLIED COLUMN
-- =====================================================

SELECT COUNT(*)
FROM retail_2
WHERE `Discount Applied` = ' ';


-- =====================================================
-- 13. FIXING BLANK DISCOUNT VALUES
-- =====================================================

UPDATE retail_2
SET `Discount Applied` = 'Unknown'
WHERE `Discount Applied` = ' ';


-- =====================================================
-- 14. FINAL VALIDATION CHECK
-- =====================================================

SELECT *
FROM retail_2
WHERE `Item` = ''
OR `Item` IS NULL;


SELECT *
FROM retail_2;


-- =====================================================
-- 15. EXPORT CLEANED DATA TO CSV
-- =====================================================

SELECT
    `Transaction ID`,
    `Customer ID`,
    `Category`,
    `Item`,
    `Price Per Unit`,
    `Quantity`,
    `Total Spent`,
    `Payment Method`,
    `Location`,
    `Transaction Date`,
    `Discount Applied`

FROM retail_2

INTO OUTFILE 'C:/temp/retail_2_cleaned.csv'

FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n';