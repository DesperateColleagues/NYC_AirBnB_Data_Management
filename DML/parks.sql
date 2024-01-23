-- 1) Rename columns to match schema
ALTER TABLE parks RENAME COLUMN gid TO id;
ALTER TABLE parks RENAME COLUMN signname TO name;
ALTER TABLE parks RENAME COLUMN typecatego TO category;

-- 2) Drop useless columns by creating a new table from parks
CREATE TABLE parks_new AS 
	SELECT gid, signname, typecatego, geom AS perimeter 
	FROM parks;

DROP TABLE parks;

ALTER TABLE parks_new RENAME TO parks; 

-- 3) Remove parks tuples that are not actual parks
DELETE FROM parks 
WHERE typecatego IN (
	'Strip', 'Lot', 'Parkway', 'Cemetery',
	'Waterfront Facility', 'Undeveloped', 'Mall'
);
						 
-- 4) Turn the invalid geometries to valid ones
UPDATE parks 
SET perimeter = St_MakeValid(perimeter)
WHERE ST_IsValid(perimeter) = 'False';

-- 5) Add a column who shows the borough in which the park lies
ALTER TABLE parks ADD COLUMN borough CHAR(2);

SELECT p.id, n.borough, COUNT(*) n
FROM parks p, neighborhoods2 n 
WHERE ST_Intersects(n.perimeter, p.perimeter) 
GROUP BY p.id, n.borough
ORDER BY n DESC;

SELECT * FROM parks WHERE borough IS NULL;
SELECT * FROM parks WHERE id = 78;




