-- This view holds all the actual resumes, since during the time a single 
-- bnb_house can have different fares for its rooms, and the rooms in 
-- this period of time can change too.
CREATE VIEW actual_resumes AS (
	SELECT *
	FROM rental_resumes rr1
	WHERE rr1.id IN (SELECT MAX(rr2.id) 
					 FROM rental_resumes rr2 
					 GROUP BY rr2.rental_unit, rr2.resume_date 
					 HAVING rr2.resume_date = MAX(rr2.resume_date))
);

-- This function is used to add a band name to a rate interval
CREATE OR REPLACE FUNCTION add_band_to_rental_unit_rate(rate DECIMAL)
RETURNS VARCHAR(50) AS 
$$	
	DECLARE band VARCHAR(50);
	BEGIN
		IF rate BETWEEN 3.50 AND 4.09 THEN
			SELECT 'average' INTO band;
		ELSEIF rate BETWEEN 4.10 AND 4.49 THEN
			SELECT 'good' INTO band;
		ELSEIF rate BETWEEN 4.50 AND 4.79 THEN
			SELECT 'very good' INTO band;
		ELSEIF rate BETWEEN 4.80 AND 5.00 THEN 
			SELECT 'execellent' INTO band;
		END IF;
		
		RETURN band;
	END
$$
LANGUAGE plpgsql;

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
			ORDER BY ru.rate DESC, ru.number_of_reviews DESC
		) SELECT * FROM sru_circle;			   
END $$;

/*
	Q1
	This query counts, for every rental unit, the number of arrests happened into an area of 100 meters 
	
*/

-- SAFATY BnB RATE
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


-- BnB CLOSER TO THE PARKS
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

SELECT MAX(number_parks) FROM parks_within_700_meters_from_sru;  --show the max number of park for the BnBs

-- Count for each neighborhood the number of BnB that are closer to more parks in an area of 1km
SELECT neighborhood, COUNT(*) AS BnB_with_more_park
FROM parks_within_700_meters_from_sru psru
WHERE number_parks BETWEEN ((SELECT MAX(number_parks) - 3 FROM parks_within_700_meters_from_sru)) AND
					(SELECT MAX(number_parks) FROM parks_within_700_meters_from_sru)
GROUP BY neighborhood
ORDER BY BnB_with_more_park DESC;


-- BnB WITH MORE TRANSPORT
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

						 	
-- POI ROUTINE 
CREATE TEMPORARY TABLE sru_circle_500_meter AS (
	SELECT * FROM create_sru_circle_x_meters(500)
);

CREATE INDEX sru_circle_500_meter_idx
	ON sru_circle_500_meter
	USING GIST(circle);
	
-- For which domain of wich poi_type?
CREATE OR REPLACE VIEW poi_within_500_meters_from_sru  AS (
	SELECT sru500.id, sru500.name, COUNT(*) AS number_poi, n.name AS neighborhood
	FROM sru_circle_500_meter sru500, poi p, neighborhoods n
	WHERE ST_Overlaps( p.coordinates, sru500.circle ) AND ST_Contains(n.perimeter, ST_Centroid(sru500.circle)) AND
	GROUP BY sru700.id, sru700.name, n.name
);

