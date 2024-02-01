-- THIS FILE MUST BE EXECUTED AFTER dml_function_make_point.sql


-- This function finds the neighborhood, that contains the point, for every geometry point in the table
CREATE OR REPLACE FUNCTION find_neighborhood(table_name TEXT)
RETURNS VOID AS
$$
	BEGIN
		EXECUTE FORMAT('UPDATE %I '
					   'SET neighborhood = n.id '
					   'FROM neighborhoods AS n '
					   'WHERE ST_Within(coordinates, n.perimeter);', table_name);
	END
$$
LANGUAGE plpgsql;

SELECT find_neighborhood('bnb_houses');
SELECT find_neighborhood('crimes');
SELECT find_neighborhood('house_sales');
SELECT find_neighborhood('poi');
SELECT find_neighborhood('subway_stops');