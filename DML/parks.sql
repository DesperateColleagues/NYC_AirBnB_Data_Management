-- Create a new table from the base parks, selecting only the column needed 
CREATE TABLE parks_new AS SELECT gid, signname, typecatego, ST_AsText(geom) AS perimeter FROM parks;

-- Drops the old parks table and rename the new one
DROP TABLE parks;
ALTER TABLE parks_new RENAME TO parks; 

-- Turn the invalid geometries to valid ones
UPDATE parks 
SET perimeter = ST_makeValid(perimeter)
WHERE St_isValid(perimeter) = 'False';

-- Remove parks tuples that are not actual parks
DELETE FROM parks 
WHERE typecatego IN ('Strip', 'Lot', 'Parkway', 'Cemetery',
						 'Waterfront Facility', 'Undeveloped', 'Mall');