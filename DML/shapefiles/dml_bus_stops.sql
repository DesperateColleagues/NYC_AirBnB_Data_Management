-- Insert data into table
INSERT INTO bus_stops (id, name, corner, coordinates)
	SELECT gid, shelter_id, corner, geom
	FROM bus_stops_temp;

-- Turn the invalid geometries to valid ones
UPDATE bus_stops 
SET coordinates = ST_MakeValid(coordinates)
WHERE St_IsValid(coordinates) = 'False';

-- Set the correct neighborhood
UPDATE bus_stops
SET neighborhood = n.id
FROM neighborhoods AS n
WHERE ST_Within(coordinates, n.perimeter);

