-- 1) Change SRID
UPDATE bus_stops
SET coordinates = ST_SetSRID(coordinates, 4326);

-- 2) Turn the invalid geometries to valid ones
UPDATE bus_stops 
SET coordinates = ST_MakeValid(coordinates)
WHERE St_IsValid(coordinates) = 'False';

-- 3) Set the correct neighborhood
UPDATE bus_stops
SET neighborhood = n.id
FROM neighborhoods AS n
WHERE ST_Within(coordinates, n.perimeter);

