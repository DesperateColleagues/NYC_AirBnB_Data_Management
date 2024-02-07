-- This table will contain the boroughs where each park belongs
CREATE TABLE positionings AS (
	SELECT b.id AS borough, p.id AS park
	FROM parks p, boroughs b
	WHERE ST_Intersects(b.perimeter, p.perimeter)
);