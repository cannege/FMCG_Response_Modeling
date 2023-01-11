-- Number of observations for each table:

SELECT COUNT(*) FROM categories; -- 50
SELECT COUNT(*) FROM customer; -- 28,593
SELECT COUNT(*) FROM customer_account; -- 35,159
SELECT COUNT(*) FROM product_groups; -- 3,913
SELECT COUNT(*) FROM customer_response; -- 13,115
SELECT COUNT(*) FROM transaction_header; -- 1,124,673
SELECT COUNT(*) FROM transaction_sale; -- 6,537,881

-- ====================================================================== customer ======================================================================
-- *Check Primary Key Column:
SELECT COUNT(DISTINCT individualnumber) = COUNT(*) FROM customer; -- True(1)

-- *TOP 10 observations:
SELECT * FROM customer LIMIT 10;

-- *Update gender 'K' as Female and 'E' as Male ('E' and 'K' represent the initials of male and female in Turkish, respectively).
UPDATE customer 
SET gender = 'Female'
WHERE gender = 'K';

UPDATE customer 
SET gender = 'Male'
WHERE gender = 'E';

-- *Check if there is an individualnumber that is not 8 digits long.
SELECT CHAR_LENGTH(individualnumber) number_of_digits, COUNT(*) Count FROM customer 
GROUP BY CHAR_LENGTH(individualnumber); -- * There are individualnumbers in dataset from 5 digits to 9 digits. Out of 28,578 observations 22,260 of them 8 digits long.

SELECT * FROM Ccstomer 
WHERE CHAR_LENGTH(individualnumber) = 6
ORDER BY dateofbirth Desc;

-- *It might be  a relation between number of digits in individualnumber and dateofbirth.
SELECT CHAR_LENGTH(individualnumber) Number_of_Digits, MAX(dateofbirth) Max_age, MIN(dateofbirth) Min_Age FROM customer
GROUP BY CHAR_LENGTH(individualnumber);

-- *Female/Male ratio:
SELECT
    COUNT(CASE WHEN gender = 'Male' THEN 1 END) / COUNT(*) AS male_ratio,
    COUNT(CASE WHEN gender = 'Female' THEN 1 END) / COUNT(*) AS female_ratio,
    COUNT(CASE WHEN gender IS NULL THEN 1 END) / COUNT(*) AS null_ratio
FROM customer; -- 53.13% male, 46.85% female, 0.02% null
 
-- *City_code distributions:
SELECT city_code, COUNT(*) FROM customer 
GROUP BY city_code
ORDER BY 2 DESC; -- 6,707 of the customers do not have city_code info. 

-- *dateofbirth descriptive statistics. 
SELECT MIN(dateofbirth) min_, MAX(dateofbirth) max_, AVG(dateofbirth) mean_, STD(dateofbirth) std_
FROM customer; -- Min: 1920, Max: 2049, Mean: 1979.9890 , std: 13.8924

-- *Group by dateofbirth and check count. 
SELECT 
(CASE 
WHEN dateofbirth >= 1920 AND dateofbirth < 1950 THEN '1920-1949'
WHEN dateofbirth >= 1950 AND dateofbirth < 1970 THEN '1950-1969'
WHEN dateofbirth >= 1970 AND dateofbirth < 1980 THEN '1970-1979'
WHEN dateofbirth >= 1980 AND dateofbirth < 1990 THEN '1980-1989'
WHEN dateofbirth >= 1990 AND dateofbirth < 2000 THEN '1990-1999'
WHEN dateofbirth >= 2000 AND dateofbirth < 2010 THEN '2000-2009'
WHEN dateofbirth >= 2010 AND dateofbirth < 2020 THEN '2010-2019'
WHEN dateofbirth >= 2010 AND dateofbirth < 2020 THEN '2010-2019'
WHEN dateofbirth >= 2020 THEN 'Borned after 2020' 
ELSE 'No dateofbirth info' 
END) 'Dateofbirth', 
COUNT(*) 
FROM customer
GROUP BY 1;

-- *Lets remove the observations that's dateofbirth 2020 or later and city_code column since 23% of observations do not have and save it in a new table customer_manipulated.
CREATE TABLE customer_temp
(SELECT individualnumber, gender, dateofbirth 
FROM customer 
WHERE dateofbirth < 2020);

-- ====================================================================== customer_account ======================================================================
-- *Check primary key column 
SELECT COUNT(DISTINCT cardnumber) = COUNT(*) FROM customer_account; -- True(1)

-- *TOP 10 observations
SELECT * FROM customer_account LIMIT 10;

-- *Number of digits of individual number. 
SELECT CHAR_LENGTH(individualnumber) number_of_digits, COUNT(*) Count FROM customer_account
GROUP BY CHAR_LENGTH(individualnumber);

-- *Number of digits of cardnumber
SELECT CHAR_LENGTH(cardnumber) number_of_digits, COUNT(*) Count FROM customer_account
GROUP BY CHAR_LENGTH(cardnumber); 

-- *Number of individuals that has more than one card.
SELECT number_of_cards, COUNT(*) FROM 
( 
SELECT individualnumber, COUNT(DISTINCT cardnumber) Number_of_Cards 
FROM customer_account 
GROUP BY individualnumber 
HAVING COUNT(*) > 1
)t1  -- 4315 out of 28,578 customers have more than one card.
GROUP BY Number_of_Cards
ORDER BY 2 DESC; -- 1055 of them have more than two cards.

-- *Store individualnumber(s) that have more than 10 cards, for later observations. 
CREATE TEMPORARY TABLE individuals_morethan10cards(
SELECT individualnumber, COUNT(*) Number_of_Cards FROM customer_account 
GROUP BY individualnumber 
HAVING COUNT(*) >= 10);

-- ====================================================================== transaction_header ======================================================================
--  *Check primary key column 
SELECT COUNT(*) = COUNT(DISTINCT basketid) FROM transaction_header; -- True(1)

-- *TOP 10 observations:
SELECT * FROM transaction_header LIMIT 10;

-- *Date range of transaction: 
SELECT MIN(date_of_transaction) Min_Date, MAX(date_of_transaction) Max_Date
FROM transAction_header; -- 2020-12-01, 2021-12-01

-- *Ratio of virtual transactions: 
SELECT 
	COUNT(CASE WHEN is_virtual = 1 THEN 1 END)/ COUNT(*) virtual_ratio,
    COUNT(CASE WHEN is_virtual = 0 THEN 1 END)/ COUNT(*) nonvirtual_ratio
FROM transaction_header; -- app %91 of the transactions are not virtual(0) 

-- ====================================================================== product_groups & categories ======================================================================
-- *No pk fo product_groups, category_number for Categories
SELECT COUNT(*) = COUNT(DISTINCT category_number) FROM categories; -- True

-- *TOP 10 observations
SELECT * FROM product_groups LIMIT 10;
SELECT * FROM categories LIMIT 10; 

-- Distinct categories 
SELECT DISTINCT category FROM categories; -- Other, Food, Hygiene, Personal_Care, Beverage

-- Check if there is duplicate observations for product_groups since it has no pk.
SELECT * , COUNT(*) FROM product_groups
GROUP BY category_number,category_level_1,category_level_2,category_level_3,category_level_4
HAVING COUNT(*) > 1; -- 4 observations

-- Create new table without duplicates, join category column from categories and name it product_groups_temp.  
CREATE TEMPORARY TABLE pg (SELECT DISTINCT * FROM product_groups);

CREATE TABLE product_groups_temp(
SELECT Category Main_Category,pg.* FROM pg
JOIN Categories c ON c.category_number = pg.category_number);

-- Check main category distribution.
SELECT 
COUNT(CASE WHEN main_category = 'food' THEN 1 END)/COUNT(*) food_ratio,
COUNT(CASE WHEN main_category = 'other' THEN 1 END)/COUNT(*) other_ratio,
COUNT(CASE WHEN main_category = 'personal_care' THEN 1 END)/COUNT(*) personalcare_ratio,
COUNT(CASE WHEN main_category = 'beverage' THEN 1 END)/COUNT(*) beverage_ratio,
COUNT(CASE WHEN main_category = 'hygiene' THEN 1 END)/COUNT(*) hygiene_ratio
FROM product_groups_temp; -- 49% Food, 36% Other, 7% Hygiene, 4% Personal care, 3% Beverage

-- ====================================================================== customer_response =====================================================================
-- *Check primary key 
SELECT COUNT(*) = COUNT(DISTINCT individualnumber) FROM customer_response; -- True 

-- *Top 10 observation 
SELECT * FROM customer_response LIMIT 10;

-- Deserved & reward amounts descriptive statistics. 
SELECT 
MIN(deserved_amount),MAX(deserved_amount),AVG(deserved_amount),STD(deserved_amount),
MIN(reward_amount),MAX(reward_amount),AVG(reward_amount),STD(reward_amount)
FROM customer_response; -- values should be normalize. 

-- Response ratio
SELECT SUM(Response)/COUNT(*) FROM customer_response; -- 0.16%

-- ====================================================================== transaction_sale ======================================================================
-- No pk 
-- Top 10 observations 
SELECT * FROM transaction_sale LIMIT 10;

-- Replace category levels (1,2,3,4) with main_category. Reduce dimension.
CREATE TABLE transaction_sale_maincat(
SELECT 
basketid, main_category, amount, quantity, discount_type_1, discount_type_2,discount_type_3
FROM transaction_sale ts
LEFT JOIN product_groups_temp pg ON 
ts.category_level_1 = pg.category_level_1 AND ts.category_level_2 = pg.category_level_2 AND ts.category_level_3 = pg.category_level_3 AND ts.category_level_4 = pg.category_level_4);

SELECT * FROM transaction_sale_maincat LIMIT 10;
SELECT COUNT(*) FROM transaction_sale_maincat WHERE main_category IS NULL; -- 0
SELECT COUNT(DISTINCT basketid) FROM transaction_sale_maincat; -- 1,063,750

-- Sales distribution(quantity) by main category.
SELECT 
SUM(CASE WHEN main_category = 'food' THEN quantity END)/SUM(quantity) Food_Quantity_Ratio, -- 65.43%
SUM(CASE WHEN main_category = 'other' THEN quantity END)/SUM(quantity) Other_Quantity_Ratio, -- 5.59%
SUM(CASE WHEN main_category = 'hygiene' THEN quantity END)/SUM(quantity) Hygiene_Quantity_Ratio, -- 8.50%
SUM(CASE WHEN main_category = 'personal_care' THEN quantity END)/SUM(quantity) PersonalCare_Quantity_Ratio, -- 1.55%
SUM(CASE WHEN main_category = 'beverage' THEN quantity END)/SUM(quantity) Beverage_Quantity_Ratio -- 18.91%
FROM transaction_sale_maincat;

-- Sales distribution(amount) by main category.
SELECT 
SUM(CASE WHEN main_category = 'food' THEN amount END)/SUM(amount) Food_Amount_Ratio, -- 64.14%
SUM(CASE WHEN main_category = 'other' THEN amount END)/SUM(amount) Other_Amount_Ratio, -- 9.61%
SUM(CASE WHEN main_category = 'hygiene' THEN amount END)/SUM(amount) Hygiene_Amount_Ratio, -- 12.71%
SUM(CASE WHEN main_category = 'personal_care' THEN amount END)/SUM(amount) PersonalCare_Amount_Ratio, -- 2.60%
SUM(CASE WHEN main_category = 'beverage' THEN amount END)/SUM(amount) Beverage_Amount_Ratio -- 10.91%
FROM transaction_sale_maincat;

-- 
-- ====================================================================== Creating Final customer_response data ====================================================================== 

-- Reshape transaction_sale data by individualnumber and name it transactiontrain.
CREATE TABLE transaction_agg(
SELECT 
individualnumber,
IFNULL(COUNT(CASE WHEN discount_type_1 > 0 THEN 1 END),0) discount_type1_count,
IFNULL(AVG(CASE WHEN discount_type_1 > 0 THEN discount_type_1 END),0) discount_type1_mean,
IFNULL(COUNT(CASE WHEN discount_type_2 > 0 THEN 1 END),0) discount_type2_count,
IFNULL(AVG(CASE WHEN discount_type_2 > 0 THEN discount_type_2 END),0) discount_type2_mean,
IFNULL(COUNT(CASE WHEN discount_type_3 > 0 THEN 1 END),0) discount_type3_count,
IFNULL(AVG(CASE WHEN discount_type_3 > 0 THEN discount_type_3 END),0) discount_type3_mean,
IFNULL(SUM(CASE WHEN main_category = 'hygiene' THEN quantity END),0) Hygiene_Quantity,
IFNULL(SUM(CASE WHEN main_category = 'hygiene' THEN amount END),0) Hygiene_Amount,
IFNULL(SUM(CASE WHEN main_category = 'other' THEN quantity END),0) Other_Quantity,
IFNULL(SUM(CASE WHEN main_category = 'other' THEN amount END),0) Other_Amount,
IFNULL(SUM(CASE WHEN main_category = 'food' THEN quantity END),0) Food_Quantity,
IFNULL(SUM(CASE WHEN main_category = 'food' THEN amount END),0) Food_Amount,
IFNULL(SUM(CASE WHEN main_category = 'personal_care' THEN quantity END),0) PersonalCare_Quantity,
IFNULL(SUM(CASE WHEN main_category = 'personal_care' THEN amount END),0) PersonalCare_Amount,
IFNULL(SUM(CASE WHEN main_category = 'beverage' THEN quantity END),0) Beverage_Quantity,
IFNULL(SUM(CASE WHEN main_category = 'beverage' THEN amount END),0) Beverage_Amount
FROM transaction_sale_maincat tsm
JOIN transaction_header th ON th.basketid = tsm.basketid
JOIN customer_account c ON c.cardnumber = th.cardnumber
WHERE quantity > 0 AND amount > 0
GROUP BY individualnumber);

SELECT COUNT(*) = COUNT(DISTINCT individualnumber) FROM transaction_agg;
SELECT COUNT(*) FROM transaction_agg;

-- JOIN customer_temp and customer_response name it customer_response_temp.
CREATE TEMPORARY TABLE customer_response_temp(
SELECT 
ct.individualnumber, gender, dateofbirth, category_number, deserved_amount,reward_amount, response 
FROM customer_temp ct
JOIN customer_response cr ON ct.individualnumber = cr.individualnumber);

-- JOIN customer_account and transaction_header to extract average virtual shopping ratio and number of purchase by individual.
CREATE TEMPORARY TABLE customeraccount_temp(
SELECT 
individualnumber,
AVG(is_virtual) isvirtual_ratio, 
COUNT(DISTINCT Basketid) purchase_count
FROM transaction_header th 
JOIN customer_account c ON c.cardnumber = th.cardnumber 
GROUP BY individualnumber);

-- Merge all three tables by individualnumber. -- customer_response_final
CREATE TABLE customer_response_final(
SELECT 
ta.*, isvirtual_ratio, gender,dateofbirth, category_number,deserved_amount, reward_amount, response
FROM transaction_agg ta
LEFT JOIN customer_response_temp USING(individualnumber) 
JOIN customeraccount_temp USING(individualnumber)
WHERE response IS NOT NULL);

-- Update Gender to 1,0 
UPDATE customer_response_final 
SET gender = 1 
WHERE gender = 'Female';

UPDATE customer_response_final
SET gender = 0 
WHERE gender = 'Male';





















































 