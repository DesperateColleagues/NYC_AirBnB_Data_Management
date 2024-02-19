-- Insert data into table
INSERT INTO boroughs (id, name, perimeter) 
	SELECT boro_code, boro_name, geom 
	FROM boroughs_temp; 

-- Turn the invalid geometries to valid ones
UPDATE boroughs 
SET perimeter = ST_MakeValid(perimeter)
WHERE St_IsValid(perimeter) = 'False';

-- Map borough numeric code to its literal
WITH borough_mapping AS (
	SELECT digit, literal
	FROM (VALUES ('1', 'MN'), ('2', 'BX'), ('3', 'BK'), ('4', 'QN'), ('5', 'SI'))
	AS boro_codes_literal (digit, literal)
) UPDATE boroughs n 
  	SET id = (
		SELECT literal 
		FROM borough_mapping bcm
		WHERE n.id = bcm.digit
  	);