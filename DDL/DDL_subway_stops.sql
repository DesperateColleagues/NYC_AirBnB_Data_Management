-- Select only the columns needed
CREATE TABLE subway_stops_new AS (
	SELECT DISTINCT stop_id AS id, stop_name AS name, 
					stop_lat AS latitude, stop_lon AS longitude
	FROM subway_stops
);

-- Add geometry column for spatial purposes
SELECT AddGeometryColumn('subway_stops','coordinates', 4326, 'POINT', 2);

DROP TABLE subway_stops;

ALTER TABLE subway_stops_new RENAME TO subway_stops;