-- This table will contain every borough in NYC
CREATE TABLE boroughs_new AS (
	SELECT boro_name AS name, boro_code AS id, geom AS perimeter
	FROM boroughs
);

DROP TABLE boroughs;

ALTER TABLE boroughs_new RENAME TO boroughs;

-- This tables will contain every POIs and POIs' types
ALTER TABLE poi RENAME COLUMN gid TO id;
ALTER TABLE poi RENAME COLUMN faci_dom TO domain;
ALTER TABLE poi RENAME COLUMN geom TO coordinates;

-- Adds the neighborhood column that will be a foreign key
ALTER TABLE poi ADD COLUMN neighborhood INTEGER;

CREATE TABLE poi_types AS (SELECT DISTINCT facility_t::INTEGER FROM poi);
ALTER TABLE poi_types RENAME COLUMN facility_t TO id;

ALTER TABLE poi_types ADD COLUMN type_desc VARCHAR(50);

CREATE TABLE poi_new AS (
	SELECT id, name, domain, facility_t::INTEGER as poi_type, neighborhood, coordinates FROM poi
);

DROP TABLE poi;

ALTER TABLE poi_new RENAME TO poi;

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
	SELECT id, name, category, geom AS perimeter 
	FROM parks;

DROP TABLE parks;

ALTER TABLE parks_new RENAME TO parks; 

ALTER TABLE parks ADD COLUMN boroughs CHAR(2)[];

-- This table will contain every bus stop
ALTER TABLE bus_stops RENAME COLUMN gid TO id;
ALTER TABLE bus_stops RENAME COLUMN shelter_id TO name;
ALTER TABLE bus_stops RENAME COLUMN geom TO coordinates;

CREATE TABLE positionings AS (
	SELECT b.id AS borough, p.id AS park
	FROM parks p, boroughs b
	WHERE ST_Intersects(b.perimeter, p.perimeter)
);

ALTER TABLE bus_stops ADD COLUMN neighborhood INTEGER;

CREATE TABLE bus_stops_new AS 
	SELECT id, name, corner, neighborhood, coordinates 
	FROM bus_stops;

DROP TABLE bus_stops;

ALTER TABLE bus_stops_new RENAME TO bus_stops;

-- This table will contain information about NYC roads
ALTER TABLE roads RENAME COLUMN gid TO id;
ALTER TABLE roads RENAME COLUMN borocode TO borough;
ALTER TABLE roads RENAME COLUMN trafdir TO traffic_direction;
ALTER TABLE roads RENAME COLUMN st_label TO name;
ALTER TABLE roads RENAME COLUMN geom TO path;
 
CREATE TABLE roads_new AS 
	SELECT id, borough, traffic_direction, name, status, path
	FROM roads;
 
DROP TABLE roads;
 
ALTER TABLE roads_new RENAME TO roads;
