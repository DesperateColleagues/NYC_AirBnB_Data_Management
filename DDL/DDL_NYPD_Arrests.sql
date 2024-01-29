-- Define the crime types table
CREATE TABLE crime_types AS (
	SELECT DISTINCT OFNS_DESC AS description 
	FROM nypd_arrests
);

ALTER TABLE crime_types ADD COLUMN id SERIAL PRIMARY KEY;

-- Define the crime table from th NYPD arrest
CREATE TABLE crimes AS (
	SELECT ARREST_KEY as id, arrest_date, ct.id as crime_type, latitude, longitude
	FROM nypd_arrests na, crime_types ct
	WHERE ct.description = na.OFNS_DESC -- map the description with its id
);

-- Cast the column back to integer
ALTER TABLE crimes ALTER COLUMN crime_type TYPE INTEGER USING crime_type::INTEGER;

-- Adds the neighborhood column that will be a foreign key
ALTER TABLE crimes ADD COLUMN neighborhood INTEGER;

-- Add the geometry column to crimes for spatial data
SELECT AddGeometryColumn ('crimes','coordinates', 4326, 'POINT', 2);

DROP TABLE nypd_arrests;