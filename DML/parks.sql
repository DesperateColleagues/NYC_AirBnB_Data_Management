-- 1) Remove parks tuples that are not actual parks
DELETE FROM parks 
WHERE category IN (
	'Strip', 'Lot', 'Parkway', 'Cemetery',
	'Waterfront Facility', 'Undeveloped', 'Mall'
);
						 
-- 2) Turn the invalid geometries to valid ones
UPDATE parks 
SET perimeter = ST_MakeValid(perimeter)
WHERE ST_IsValid(perimeter) = 'False';

UPDATE parks p1
SET boroughs = (
	SELECT ARRAY(
		SELECT n.borough::char(2)
		FROM parks p2, neighborhoods n 
		WHERE ST_Intersects(n.perimeter, p2.perimeter) AND 
			  p2.id = P1.id
		GROUP BY p2.id, n.borough
));