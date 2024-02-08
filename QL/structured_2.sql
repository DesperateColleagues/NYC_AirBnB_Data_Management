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
    Count the bnb number in a specific borough with ideal charatteristics.
*/

SELECT b.name AS borough, COUNT(*) AS number_bnb
FROM ideal_rental_unit_per_band_rate iru, rental_resumes rs, rental_fares rf, rental_units ru, room_configurations rc, neighborhoods n, boroughs b
WHERE rf.id = rs.rental_fare AND rc.id = rs.room_configuration AND ru.id = rs.rental_unit AND
		rf.price BETWEEN iru.avg_price-10 AND iru.avg_price+10 AND
		rc.n_beds = iru.avg_number_of_beds AND rc.n_baths = iru.avg_number_of_baths AND rc.is_bath_shared = iru.mode_bath_shared AND
		ru.availability_rate_365 BETWEEN iru.avg_availability_rate_365-0.5 AND iru.avg_availability_rate_365+0.5 AND
		ru.neighborhood = n.id AND n.borough = b.id AND iru.rental_unit_band = 'execellent'
GROUP BY b.name;


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