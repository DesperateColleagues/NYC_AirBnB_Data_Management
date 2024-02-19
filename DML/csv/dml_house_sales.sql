-- 0) Insert data into table
INSERT INTO house_sales(tax_class, sqft, price, construction_year, address, latitude, longitude)
	SELECT TAX_CLASS_AT_PRESENT, LAND_SQUARE_FEET, SALE_PRICE,
		   YEAR_BUILT, address, latitude, longitude
	FROM house_sales_temp
	WHERE LAND_SQUARE_FEET IS NOT NULL;

-- Where the price is so low, it is considered as a
-- property swap (which is indicated by 0 for price)
UPDATE house_sales
SET price = 0
WHERE price = 10;