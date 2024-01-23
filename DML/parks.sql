-- 1) Rename columns to match schema
ALTER TABLE parks RENAME COLUMN gid TO id;
ALTER TABLE parks RENAME COLUMN signname TO name;
ALTER TABLE parks RENAME COLUMN typecatego TO category;

-- 2) Drop useless columns by creating a new table from parks
CREATE TABLE parks_new AS 
	SELECT id, name, category, geom AS perimeter 
	FROM parks;

DROP TABLE parks;

ALTER TABLE parks_new RENAME TO parks; 

-- 3) Remove parks tuples that are not actual parks
DELETE FROM parks 
WHERE category IN (
	'Strip', 'Lot', 'Parkway', 'Cemetery',
	'Waterfront Facility', 'Undeveloped', 'Mall'
);
						 
-- 4) Turn the invalid geometries to valid ones
UPDATE parks 
SET perimeter = ST_MakeValid(perimeter)
WHERE ST_IsValid(perimeter) = 'False';

-- 5) Add a column who shows the borough in which the park lies
ALTER TABLE parks ADD COLUMN boroughs CHAR(2)[];

UPDATE parks p1
SET boroughs = (
	SELECT ARRAY(
		SELECT n.borough::char(2)
		FROM parks p2, neighborhoods n 
		WHERE ST_Intersects(n.perimeter, p2.perimeter) AND p2.id = P1.id
		GROUP BY p2.id, n.borough
))