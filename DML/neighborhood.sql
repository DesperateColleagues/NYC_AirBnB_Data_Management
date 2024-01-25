-- 1) Turn the invalid geometries to valid ones
UPDATE neighborhoods 
SET perimeter = ST_MakeValid(perimeter)
WHERE St_IsValid(perimeter) = 'False';

-- 2) Replace the name of the borough with its code (it will be FK key)
UPDATE neighborhoods n
SET borough = (
	SELECT id 
	FROM borough b
	WHERE b.name = n.borough
);

-- 3) Change SRID
UPDATE neighborhoods
SET perimeter = ST_SetSRID(perimeter, 4326);