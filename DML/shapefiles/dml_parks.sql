-- Insert data into table
INSERT INTO parks(name, category, perimeter)
	SELECT signname, typecatego, geom
	FROM parks_temp;

-- Turn the invalid geometries to valid ones
UPDATE parks 
SET perimeter = ST_MakeValid(perimeter)
WHERE ST_IsValid(perimeter) = 'False';

-- Remove parks tuples that are not actual parks
DELETE FROM parks 
WHERE category IN (
	'Strip', 'Lot', 'Parkway', 'Cemetery',
	'Waterfront Facility', 'Undeveloped', 'Mall'
);
						
-- Insert value into positionings (n n table)
INSERT INTO positionings 
	SELECT b.id AS borough, p.id AS park
	FROM parks p, boroughs b
	WHERE ST_Intersects(b.perimeter, p.perimeter);