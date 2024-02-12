-- 0) Insert data into table
INSERT INTO parks(name, category, perimeter)
	SELECT signname, typecatego, geom
	FROM parks_temp;

-- 1) Change SRID
UPDATE parks
SET perimeter = ST_SetSRID(perimeter, 4326);

-- 2) Remove parks tuples that are not actual parks
DELETE FROM parks 
WHERE category IN (
	'Strip', 'Lot', 'Parkway', 'Cemetery',
	'Waterfront Facility', 'Undeveloped', 'Mall'
);
						 
-- 3) Turn the invalid geometries to valid ones
UPDATE parks 
SET perimeter = ST_MakeValid(perimeter)
WHERE ST_IsValid(perimeter) = 'False';

-- 4) Set parks' borough
UPDATE parks p1
SET boroughs = (
	SELECT ARRAY(
		SELECT n.borough::char(2)
		FROM parks p2, neighborhoods n 
		WHERE ST_Intersects(n.perimeter, p2.perimeter) AND 
			  p2.id = P1.id
		GROUP BY p2.id, n.borough
));

-- 5) Insert value into positionings (n n table)
INSERT INTO positionings 
	SELECT b.id AS borough, p.id AS park
	FROM parks p, boroughs b
	WHERE ST_Intersects(b.perimeter, p.perimeter);