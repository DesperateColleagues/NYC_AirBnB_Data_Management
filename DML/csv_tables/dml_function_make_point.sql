CREATE OR REPLACE FUNCTION make_point(table_name TEXT)
RETURNS VOID AS 
$$
	BEGIN
		EXECUTE FORMAT('UPDATE %I SET coordinates = ST_SetSRID(ST_MakePoint(longitude, latitude), 4326);', table_name);
	END
$$
LANGUAGE plpgsql;

-- 1) convert coordinates into POINT geometry
SELECT make_point('crimes');
SELECT make_point('subway_stops');
SELECT make_point('bnb_houses');
SELECT make_point('house_sales');
