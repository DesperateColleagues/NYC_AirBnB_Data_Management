-- Define the crime types table
CREATE TABLE crime_types AS (
	SELECT DISTINCT OFNS_DESC AS description 
	FROM nypd_arrests
);

ALTER TABLE crime_types ADD COLUMN id SERIAL PRIMARY KEY;

-- Define the crime table from th NYPD arrest
CREATE TABLE crimes AS (
	SELECT ARREST_KEY as id, arrest_date, OFNS_DESC as crime_type, latitude, longitude
	FROM nypd_arrests
);

-- Add the geometry column to crimes for spatial data
SELECT AddGeometryColumn ('crimes','coordinates', 4326, 'POINT', 2);

DROP TABLE nypd_arrests;