-- 1) Turn the invalid geometries to valid ones
UPDATE roads 
SET path = ST_MakeValid(path)
WHERE ST_IsValid(path) = 'False';

-- 2) Set the correct borough id via a mapping
WITH borough_mapping AS (
	SELECT digit, literal
	FROM (VALUES ('1', 'MN'), ('2', 'BX'), ('3', 'BK'), ('4', 'QN'), ('5', 'SI'))
	AS boro_codes_literal (digit, literal)
) UPDATE roads n 
  	SET borough = (
		SELECT literal 
		FROM borough_mapping bcm
		WHERE n.borough = bcm.digit
  	);

-- 3) Substitute road status with its literal form
WITH status_mapping AS (
	SELECT digit, literal
	FROM (VALUES ('2', 'Constructed'), ('5', 'Demapped'))
	AS status_values (digit, literal)
) UPDATE roads n
	SET status = (
		SELECT literal
		FROM status_mapping sm
		WHERE n.status = sm.digit
	);