-- 1) Change SRID
UPDATE boroughs
SET perimeter = ST_SetSRID(perimeter, 4326);

-- 2) Turn the invalid geometries to valid ones
UPDATE boroughs 
SET perimeter = ST_MakeValid(perimeter)
WHERE St_IsValid(perimeter) = 'False';

-- 3) Cast borough column to integer to remove decimals and then to a CHAR(2)
ALTER TABLE boroughs ALTER COLUMN id TYPE INTEGER USING id::integer;
ALTER TABLE boroughs ALTER COLUMN id TYPE CHAR(2);

-- 4) Map borough numeric code to its literal
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