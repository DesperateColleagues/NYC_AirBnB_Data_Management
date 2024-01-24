-- This table will contain every borough
CREATE TABLE IF NOT EXISTS borough (
	id CHAR(2) NOT NULL PRIMARY KEY,
	name VARCHAR(15)
);

-- This tables will contain every POIs and POIs' types
ALTER TABLE poi RENAME COLUMN gid TO id;
ALTER TABLE poi RENAME COLUMN faci_dom TO domain;
ALTER TABLE poi RENAME COLUMN geom TO coordinates;

CREATE TABLE poi_type AS (SELECT DISTINCT facility_t::INTEGER FROM poi);
ALTER TABLE poi_type RENAME COLUMN facility_t TO id;

ALTER TABLE poi_type ADD COLUMN type_desc VARCHAR(50);

CREATE TABLE POI_NEW AS (
	SELECT id, name, domain, facility_t::INTEGER as poi_type, coordinates FROM poi
);

DROP TABLE poi;

ALTER TABLE POI_NEW RENAME TO poi;

-- This table will contain every neighborhoods
ALTER TABLE neighborhoods RENAME COLUMN gid TO id;
ALTER TABLE neighborhoods RENAME COLUMN ntaname TO name;
ALTER TABLE neighborhoods RENAME COLUMN boroname TO borough;
ALTER TABLE neighborhoods RENAME COLUMN geom TO perimeter;

CREATE TABLE neighborhoods_new AS (
	SELECT id, name, borough, perimeter 
	FROM neighborhoods
);

DROP TABLE neighborhoods;

ALTER TABLE neighborhoods_new RENAME TO neighborhoods;

-- This table will contain every park
ALTER TABLE parks RENAME COLUMN gid TO id;
ALTER TABLE parks RENAME COLUMN signname TO name;
ALTER TABLE parks RENAME COLUMN typecatego TO category;

CREATE TABLE parks_new AS 
	SELECT gid, signname, typecatego, geom AS perimeter 
	FROM parks;

DROP TABLE parks;

ALTER TABLE parks_new RENAME TO parks; 

-- Add a column who shows the borough in which the park lies
ALTER TABLE parks ADD COLUMN boroughs CHAR(2)[];
