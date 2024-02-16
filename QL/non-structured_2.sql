-- 150 points on the park border
CREATE TEMPORARY TABLE Central_Park_decomposition AS (
WITH tbla AS (
	SELECT (ST_ExteriorRing(((ST_Dump(p.perimeter)).geom))) geom FROM parks p WHERE p.name LIKE 'Central Park'), 
	intervals AS (SELECT generate_series (0, 49) as steps) 
	SELECT steps AS stp, 
	ST_LineInterpolatePoint(geom, steps/(SELECT count(steps)::float - 1 FROM intervals)) geom
	FROM tbla, intervals 
	GROUP BY intervals.steps, geom
);

-- The first road nearest to the park extern border
CREATE TEMPORARY TABLE nearest_street_from_park_border_point AS (
	SELECT roads.id, roads.name, roads.dist, roads.path
	FROM Central_Park_decomposition cpd
		CROSS JOIN LATERAL (
		SELECT r.*, r.path::geography <-> cpd.geom::geography AS dist
		FROM roads r
		WHERE ST_Intersects(r.path, (SELECT perimeter FROM parks WHERE name LIKE 'Central Park')) = FALSE
		ORDER BY dist
		LIMIT 5

	) AS roads
);

-- This select shows why the limit in nearest_street_from_park_border_point has been 
-- setted to 5
SELECT * FROM nearest_street_from_park_border_point;

-- The house sales about circa low then 700 mt from the park border 
CREATE TEMPORARY TABLE house_sales_within_700_meters AS (
	WITH house_sales_in_MN AS (
		SELECT hs.*
		FROM house_sales hs, boroughs b
		WHERE ST_Contains(b.perimeter, hs.coordinates) AND b.id = 'MN' AND 
			  (hs.tax_class LIKE '1%' OR hs.tax_class LIKE '2%') AND hs.price <> 0
	)
	SELECT DISTINCT hsmn.id, hsmn.coordinates
	FROM house_sales_in_MN hsmn, Central_Park_decomposition cpd
	WHERE ST_DWithin(hsmn.coordinates::geography, cpd.geom::geography, 700)
);

SELECT * FROM house_sales_within_700_meters;

-- The first three roads nearest to the house sales about circa low then 700 mt from the park border 
CREATE TEMPORARY TABLE nearest_street_from_house_sales AS (
	SELECT roads.hs_id, roads.id AS road_id, roads.name AS road_name, roads.dist AS road_dist
	FROM house_sales_within_700_meters hs700
		CROSS JOIN LATERAL (
		SELECT r.*, r.path::geography <-> hs700.coordinates::geography AS dist, hs700.id AS hs_id
		FROM roads r
		ORDER BY dist
		LIMIT 3
	) AS roads
);
--TODO MAKE JOIN WITH ST_EQUALS ON THE ROADS

-- This query shows the final result
WITH 
house_sales_around_cp AS ( -- Find house near to park
	SELECT DISTINCT nsfhs.hs_id AS id
	FROM nearest_street_from_house_sales nsfhs, nearest_street_from_park_border_point nsfpbp
	WHERE nsfhs.road_id = nsfpbp.id  
), 
house_sales_not_around_cp AS ( -- Find house far from house
	SELECT ROUND(AVG(hs1.price), 2) AS avg_price_MN
	FROM house_sales hs1, neighborhoods n
	WHERE hs1.neighborhood = n.id AND n.borough LIKE 'MN' AND hs1.id NOT IN (SELECT id FROM house_sales_around_cp)
)
SELECT 	ROUND(AVG(price), 2) AS avg_price_around_cp, -- Find average price for bouth type of house sets
		(SELECT avg_price_MN FROM house_sales_not_around_cp)
FROM 	house_sales hs2, house_sales_around_cp hsacp
WHERE hs2.id = hsacp.id;



