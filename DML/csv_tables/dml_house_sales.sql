-- Where the price is so low, it is considered as a
-- property swap (which is indicated by 0 for price)
UPDATE house_sales
SET price = 0
WHERE price = 10