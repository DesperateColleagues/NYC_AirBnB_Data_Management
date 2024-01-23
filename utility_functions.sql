-- This function returns the code related to a borough name
CREATE OR REPLACE FUNCTION boro_code_from_name(boro_name VARCHAR(15))
	RETURNS CHAR(2) AS 'SELECT id FROM borough WHERE boro_name = name;'
LANGUAGE SQL;