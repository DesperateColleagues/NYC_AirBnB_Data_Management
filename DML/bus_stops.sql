UPDATE bus_stops
SET neighborhood = n.id
FROM neighborhoods AS n
WHERE ST_Within(coordinates, n.perimeter);


