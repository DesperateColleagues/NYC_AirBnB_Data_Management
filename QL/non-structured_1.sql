/* All the views/temporary tables that are used in this script without report the creation code are reported
 in scripts made for structured side.
 
 <NAME view/temporary table/function> -> <NAME script file>:
 
 @ VIEW actual_resumes -> structured_1.sql
 @ 
 
*/

CREATE OR REPLACE FUNCTION create_sru_circle_x_meters(radius integer)
RETURNS TABLE (id bigint, name character varying, rate numeric, number_of_reviews integer,
			   availability_rate_365 numeric, license boolean, neighborhood integer, circle geometry) 
LANGUAGE 'plpgsql' AS 
$$
BEGIN
	RETURN QUERY
		WITH sru_circle AS (
			SELECT 	ru.id, ru.name, ru.rate, ru.number_of_reviews, ru.availability_rate_365, 
					ru.license, ru.neighborhood,
					ST_Buffer(ru.coordinates::geography, $1, 'quad_segs=16')::geometry AS circle
			FROM 	rental_units ru
			WHERE 	ru.number_of_reviews > 50 AND ru.rate BETWEEN 3.5 AND 5
		) SELECT * FROM sru_circle;			   
END $$;

----------------------------------------------------------------------------------------------------------------------------------------------------
/*
	Q1
	
	This query allows to find some new poi domains based on the following criterion:
	Show all the poi domains that have a total BnB density in an area of 500 meters >= 
	50% bnb density of pois of the same poi_type.
	the results suggests that there are some poi domain in NYC that are considered useful for the BnB business.
*/

CREATE TEMPORARY TABLE IF NOT EXISTS poi_circle_500_meter AS (
	SELECT 	id, name, domain, poi_type, neighborhood,
		ST_Buffer(coordinates::geography, 500, 'quad_segs=16')::geometry AS circle
	FROM 	poi
);

CREATE INDEX IF NOT EXISTS poi_circle_500_meter_idx
	ON poi_circle_500_meter
	USING GIST(circle);	

WITH rental_units_density_for_poi AS (
	SELECT 	poi500.poi_type, poi500.domain, COUNT(*) AS rental_units_density
	FROM 	poi_circle_500_meter poi500, significant_rental_units sru
	WHERE 	ST_Intersects(sru.coordinates, poi500.circle) AND poi500.domain <> 'Other'
	GROUP BY poi500.poi_type, poi500.domain
)
SELECT domain
FROM (SELECT poi_type, domain, SUM(rental_units_density) AS rud_for_domain
	  FROM rental_units_density_for_poi
	  GROUP BY poi_type, domain) poi_rud1
WHERE rud_for_domain >= (SELECT SUM(poi_rud2.rental_units_density) * 0.5
						 FROM   rental_units_density_for_poi poi_rud2
						 WHERE 	poi_rud1.poi_type = poi_rud2.poi_type
						 GROUP BY poi_rud2.poi_type);

----------------------------------------------------------------------------------------------------------------------------------------------------
/*
	Q2
	
							*******SAFETY BnB RATE FOR NEIGHBORHOODS*******
	
	This query shows, for every neighborhood a BnB safety rate that describes how many bnb 
	counts the minimum amount of arrests happened in an area of 100 meters from the bnb.
	(the bnb is considered the center point of this area)
*/

CREATE TEMPORARY TABLE sru_circle_100_meter AS (
	SELECT * FROM create_sru_circle_x_meters(100)
);

CREATE INDEX sru_circle_100_meter_idx
	ON sru_circle_100_meter
	USING GIST(circle);
	
CREATE OR REPLACE VIEW sru_with_at_least_one_arrests_in_range_100_meters AS (
	SELECT 	sru100.id, sru100.name, COUNT(*) AS number_arrests, n.name AS neighborhood
	FROM 	sru_circle_100_meter sru100, arrests a, neighborhoods n
	WHERE 	ST_Intersects(a.coordinates, sru100.circle) AND ST_Contains(n.perimeter, ST_Centroid(sru100.circle))
	GROUP BY sru100.id, sru100.name, n.name
);

-- This view is necessary to count neighborhoods whose BNB does not have any arrests 
-- in the chosen area
CREATE OR REPLACE VIEW sru_without_arrests_in_range_100_meters AS (
	SELECT 	sru100.id, sru100.name, 0 AS number_arrests, n.name AS neighborhood
	FROM 	sru_circle_100_meter sru100, neighborhoods n
	WHERE 	sru100.id NOT IN (SELECT id FROM sru_with_at_least_one_arrests_in_range_100_meters) AND
			ST_Contains(n.perimeter, ST_Centroid(sru100.circle))
);

CREATE OR REPLACE VIEW arrests_within_100_meters_from_sru AS (
		SELECT * FROM sru_with_at_least_one_arrests_in_range_100_meters 
	  	UNION 
	  	SELECT * FROM sru_without_arrests_in_range_100_meters
);

-- Select for each neighborhood the rate of safe bnbs: the ones with the smaller amount
-- of arrests in an area of 100 meters
SELECT neighborhood, ROUND((COUNT(*)::DECIMAL / (SELECT COUNT(*)
								  FROM arrests_within_100_meters_from_sru 
								  WHERE asru.neighborhood = neighborhood)), 2) AS safe_rental_units_rate
FROM arrests_within_100_meters_from_sru asru
WHERE asru.number_arrests = (SELECT MIN(number_arrests) FROM arrests_within_100_meters_from_sru)
GROUP BY neighborhood
ORDER BY safe_rental_units_rate;


----------------------------------------------------------------------------------------------------------------------------------------------------
/*
	Q3
	
								*******BnB CLOSER TO THE PARKS*******
	
	This query counts, for the neighborhoods, the number of bnb whose parks' occurrences lies 
	in a specific range (MAX - x, MAX) in an area of 700 meters.
	(the bnb is considered the center point of this area).
*/

CREATE TEMPORARY TABLE sru_circle_700_meter AS (
	SELECT * FROM create_sru_circle_x_meters(700)
);

CREATE INDEX sru_circle_700_meter_idx
	ON sru_circle_700_meter
	USING GIST(circle);

CREATE OR REPLACE VIEW parks_within_700_meters_from_sru  AS (
	SELECT sru700.id, sru700.name, COUNT(*) AS number_parks, n.name AS neighborhood
	FROM sru_circle_700_meter sru700, parks p, neighborhoods n
	WHERE ST_Overlaps(p.perimeter, sru700.circle) AND ST_Contains(n.perimeter, ST_Centroid(sru700.circle))
	GROUP BY sru700.id, sru700.name, n.name
);

CREATE OR REPLACE VIEW parks_within_700_meters_from_sru  AS (
	SELECT 	sru.id, sru.name, COUNT(*) AS number_parks, n.name AS neighborhood
	FROM 	significant_rental_units sru, parks p, neighborhoods n
	WHERE 	ST_DWithin(p.perimeter::geography, sru.coordinates::geography, 700) AND 
			ST_Contains(n.perimeter, sru.coordinates)
	GROUP BY sru.id, sru.name, n.name
);

SELECT MAX(number_parks) FROM parks_within_700_meters_from_sru;  --show the max number of park for the BnBs

-- Count for each neighborhood the number of BnB that are closer to more parks in an area of 1km
SELECT neighborhood, COUNT(*) AS BnB_with_more_park
FROM parks_within_700_meters_from_sru psru
WHERE number_parks BETWEEN ((SELECT MAX(number_parks) - 3 FROM parks_within_700_meters_from_sru)) AND
					(SELECT MAX(number_parks) FROM parks_within_700_meters_from_sru)
GROUP BY neighborhood
ORDER BY BnB_with_more_park DESC;

----------------------------------------------------------------------------------------------------------------------------------------------------
/*
	Q4
	
							*******BnB WITH MORE TRANSPORT STOPS*******
	
	This query counts, for the neighborhoods, the number of bnb whose bus or subway stops occurrences 
	lies in a specific range (MAX - x, MAX) in an area of 1000 meters.
	(the bnb is considered the center point of this area).
*/

CREATE TEMPORARY TABLE sru_circle_1km AS (
	SELECT * FROM create_sru_circle_x_meters(1000)
);

CREATE INDEX sru_circle_1km_idx
	ON sru_circle_1km
	USING GIST(circle);

CREATE OR REPLACE VIEW transport_stops_within_1km_from_sru  AS (
	WITH t AS (
	SELECT sru1km.id, sru1km.name, COUNT(*) AS number_transport_stop, n.name AS neighborhood
	FROM sru_circle_1km sru1km, subway_stops ss, neighborhoods n
	WHERE ST_Intersects( ss.coordinates, sru1km.circle) AND ST_Contains(n.perimeter, ST_Centroid(sru1km.circle))
	GROUP BY sru1km.id, sru1km.name, n.name
	
	UNION
	
	SELECT sru1km.id, sru1km.name, COUNT(*) AS number_transport_stop, n.name AS neighborhood
	FROM sru_circle_1km sru1km, bus_stops bs, neighborhoods n
	WHERE ST_Intersects(bs.coordinates, sru1km.circle ) AND ST_Contains(n.perimeter, ST_Centroid(sru1km.circle))
	GROUP BY sru1km.id, sru1km.name, n.name
	) 
	SELECT id, name, SUM(number_transport_stop) AS number_transport_stop, neighborhood
	FROM t
	GROUP BY id, name, neighborhood
);

SELECT MAX(bnb_with_more_transport) FROM transport_stops_within_1km_from_sru;  --show the max number of transport stops for the BnBs = 83

-- Count for each neighborhood the number of BnB that are closer to more transport stops in an area of 1km
SELECT neighborhood, COUNT(*) AS bnb_with_more_transport, 
FROM transport_stops_within_1km_from_sru tsru
WHERE number_transport_stop >= 20
GROUP BY neighborhood
ORDER BY bnb_with_more_transport DESC;

----------------------------------------------------------------------------------------------------------------------------------------------------
/*
	Q5
	
									*******BNB DENSITY PER POI*******
									
	This query shows the first ten neighborhoods with an high concentration of rental units 
	that contains the following type of pois, in an area of 500 meters.
	(the bnb is considered the center point of this area).
	
	The poi categories considered are the following:
	- daily routine: 'Pool', 'Market', 'Sports', 'Bridge'
	- free time: 'Zoo', 'Library', 'Museum', 'Theater/Concert Hall', 'Restaurant', 'Church'
	- emergency: 'Hospital', 'Day Care Center'
	
*/
CREATE TEMPORARY TABLE sru_circle_500_meter AS (
	SELECT * FROM create_sru_circle_x_meters(500)
);

CREATE INDEX sru_circle_500_meter_idx
	ON sru_circle_500_meter
	USING GIST(circle);

-- This function return a table with the count of poi that lie in 500 meters
-- from a significant rental unit. The poi to be counted are selected from the 
-- input parameter
CREATE OR REPLACE FUNCTION count_poi_in_sru_500_meters_ares(dom_list TEXT[])
RETURNS TABLE (id BIGINT, neighborhood VARCHAR(100), tot BIGINT)
LANGUAGE 'plpgsql' AS 
$$
BEGIN
	RETURN QUERY
		SELECT 	sru500.id, n.name AS neighborhood, COUNT(*) AS tot
		FROM 	sru_circle_500_meter sru500, neighborhoods n, poi
		WHERE 	ST_Contains(sru500.circle, poi.coordinates) AND
				ST_Contains(n.perimeter, ST_Centroid(sru500.circle)) AND
				poi.domain = ANY(dom_list)
		GROUP BY sru500.id, n.name;
END;
$$

-- Q5.1
SELECT n.borough, dr.neighborhood, COUNT(*) AS bnb_with_more_daily_routine_poi
FROM (SELECT * 
	  FROM count_poi_in_sru_500_meters_ares(ARRAY['Pool', 'Market', 'Sports', 'Bridge'])) AS dr,
	  neighborhoods n
WHERE n.name = dr.neighborhood
GROUP BY dr.neighborhood, n.borough
ORDER BY bnb_with_more_daily_routine_poi DESC
LIMIT 10;

-- Q5.2
SELECT n.borough, ft.neighborhood, COUNT(*) AS bnb_with_more_free_time_poi
FROM (SELECT * 
	  FROM count_poi_in_sru_500_meters_ares(ARRAY['Zoo', 'Library', 'Museum', 
												  'Theater/Concert Hall', 'Restaurant', 'Church'])) AS ft,
	  neighborhoods n
WHERE n.name = ft.neighborhood
GROUP BY ft.neighborhood, n.borough
ORDER BY bnb_with_more_free_time_poi DESC
LIMIT 10;

-- Q5.3
SELECT n.borough, e.neighborhood, COUNT(*) AS bnb_with_more_emergency_poi
FROM (SELECT * FROM count_poi_in_sru_500_meters_ares(ARRAY['Hospital', 'Day Care Center'])) AS e,
	  neighborhoods n
WHERE n.name = e.neighborhood
GROUP BY e.neighborhood, n.borough
ORDER BY bnb_with_more_emergency_poi DESC
LIMIT 10;