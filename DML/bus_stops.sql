UPDATE bus_stops
SET neighborhood = n.id
FROM neighborhoods AS n
WHERE ST_Within(coordinates, n.perimeter);

-- 2) Change SRID
UPDATE bus_stops
SET coordinates = ST_SetSRID(coordinates, 4326);