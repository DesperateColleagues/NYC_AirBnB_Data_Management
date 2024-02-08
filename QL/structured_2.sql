/*
	Q4
	List all the borough based on the crime rate from the lower to the higher.
*/

WITH total_crimes AS (
	SELECT COUNT(*) AS tot
	FROM crimes
	
)	SELECT b.name AS borough, 
		   ROUND(CAST(COUNT(*) AS DECIMAL) / CAST((SELECT * FROM total_crimes) AS DECIMAL), 2) AS crime_rate
	FROM neighborhoods n, crimes c, boroughs b
	WHERE n.id = c.neighborhood AND b.id = n.borough 
	GROUP BY b.name
	ORDER BY n_crime ASC;
	
/*
	Q5
	
*/


/*
	Q6
	List all the borough based on the poi, parks, bus and subway stops number.
*/
CREATE OR REPLACE FUNCTION count_poi_types(poi_type INTEGER, borough_name VARCHAR(255))
RETURNS INTEGER AS
$$
	SELECT COUNT(*) AS tot
	FROM poi, neighborhoods n, boroughs b
	WHERE n.id = poi.neighborhood AND b.id = n.borough AND
		  b.name = $2 AND poi.poi_type = $1;
$$
LANGUAGE SQL;

CREATE TEMPORARY TABLE IF NOT EXISTS count_bus_stops AS (
	SELECT b.name AS borough, COUNT(*) bus_stops_count
	FROM bus_stops bs, neighborhoods n, boroughs b 
	WHERE n.id = bs.neighborhood AND b.id = n.borough
	GROUP BY b.name
);

CREATE TEMPORARY TABLE IF NOT EXISTS count_subway_stops AS (
	SELECT b.name AS borough, COUNT(*) subway_stops_count
	FROM subway_stops ss, neighborhoods n, boroughs b 
	WHERE n.id = ss.neighborhood AND b.id = n.borough
	GROUP BY b.name
);

CREATE TEMPORARY TABLE IF NOT EXISTS count_poi AS (
	SELECT b.name AS borough, 
	       count_poi_types(7, b.name) AS commercial_poi_count,
	       count_poi_types(10, b.name) AS health_services_poi_count,
		   count_poi_types(4, b.name) AS recreational_poi_count
	FROM boroughs b
);

SELECT cp.borough, bus_stops_count, subway_stops_count, 
       commercial_poi_count, health_services_poi_count, recreational_poi_count
FROM count_poi cp, count_subway_stops css, count_bus_stops cbs
WHERE cp.borough = css.borough AND cp.borough = cbs.borough;