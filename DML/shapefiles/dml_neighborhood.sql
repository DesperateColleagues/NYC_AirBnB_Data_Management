-- Insert data into table
INSERT INTO neighborhoods (id, name, borough, perimeter)
	SELECT gid, ntaname, b.id, geom
	FROM neighborhoods_temp n, boroughs b
	WHERE b.name = n.boroname;

-- Turn the invalid geometries to valid ones
UPDATE neighborhoods 
SET perimeter = ST_MakeValid(perimeter)
WHERE St_IsValid(perimeter) = 'False';