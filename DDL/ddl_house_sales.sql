-- Select only the columns needed
CREATE TABLE house_sales_new AS (
	SELECT TAX_CLASS_AT_PRESENT AS tax_class, 
		   LAND_SQUARE_FEET AS sqft, SALE_PRICE AS price,
		   YEAR_BUILT AS construction_year, address, latitude, longitude
	FROM house_sales
	WHERE LAND_SQUARE_FEET IS NOT NULL
);

DROP TABLE house_sales;

ALTER TABLE house_sales_new RENAME TO house_sales;

-- Adds the neighborhood column that will be a foreign key
ALTER TABLE house_sales ADD COLUMN neighborhood INTEGER;
ALTER TABLE house_sales ADD COLUMN id SERIAL;

-- Add geometry column for spatial purposes
SELECT AddGeometryColumn('house_sales','coordinates', 4326, 'POINT', 2);