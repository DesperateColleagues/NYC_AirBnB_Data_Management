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

SELECT * FROM actual_resumes;

/*
	Q1
	
	Find significant rental units, the ones with a number of review 
	above 50 and a rate between 3.5 and 5
*/
CREATE OR REPLACE VIEW significant_rental_units AS (
	SELECT id, name, rate, number_of_reviews, availability_rate_365
	FROM rental_units
	WHERE number_of_reviews > 50 AND rate BETWEEN 3.5 AND 5
	ORDER BY rate DESC, number_of_reviews DESC
);

SELECT * FROM significant_rental_units;

/*
	Q2

	Count how many bnb respects (and not) the new rent compliances rules.
	Note: This is helpful to understand if the market shifted to long term rents
		  rather than continuing short term rents.
*/

-- This function count the number of compliant bnb according to the input parameter
CREATE OR REPLACE FUNCTION count_compliances(is_compliant BOOLEAN)
RETURNS INTEGER AS
$$
	DECLARE comp_count INTEGER;
	DECLARE COMPLIANT_LIMIT INTEGER := 30;
	
	BEGIN 
		CREATE TABLE no_licenses_units AS (
   			SELECT ru.id, rf.minimum_nights 
			FROM rental_units ru, actual_resumes ar, rental_fares rf
			WHERE ru.id = ar.rental_unit AND rf.id = ar.rental_fare AND ru.license = false
		);
		
		IF is_compliant THEN 
			SELECT count(*) INTO comp_count 
			FROM no_licenses_units nlu
			WHERE nlu.minimum_nights >= COMPLIANT_LIMIT;
		ELSE 
			SELECT count(*) INTO comp_count 
			FROM no_licenses_units nlu
			WHERE nlu.minimum_nights < COMPLIANT_LIMIT;
		END IF;
		
		DROP TABLE no_licenses_units;
			
		RETURN comp_count;
	END
$$
LANGUAGE plpgsql;

SELECT count_compliances(TRUE) AS compliant_bnb, 
       count_compliances(FALSE) AS not_compliant_bnb;
	   
/*
	Q3 
	Find the ideal rental unit, by aggregating data like price, number of beds and bathroo 
    and if the bath is shared or not (since it's a categorical feature the mode can be used to aggregate)
*/

-- This function returns the count of rows from a "special" table named temp_mode
-- based on the band given in input.
CREATE OR REPLACE FUNCTION count_by_rate_bands(bnb_band VARCHAR(50))
RETURNS INTEGER AS
$$
	DECLARE n INTEGER;
	
	BEGIN
		IF bnb_band LIKE 'average' THEN
			SELECT COUNT(*) INTO n FROM temp_mode tm WHERE tm.rate BETWEEN 3.50 AND 4.09;
		ELSEIF bnb_band LIKE 'good' THEN
			SELECT COUNT(*) INTO n FROM temp_mode tm WHERE tm.rate BETWEEN 4.10 AND 4.49;
		ELSEIF bnb_band LIKE 'very good' THEN
			SELECT COUNT(*) INTO n FROM temp_mode tm WHERE tm.rate BETWEEN 4.50 AND 4.79;
		ELSEIF bnb_band LIKE 'execellent' THEN
			SELECT COUNT(*) INTO n FROM temp_mode tm WHERE tm.rate BETWEEN 4.80 AND 5.00;
		END IF;
		
		DROP TABLE temp_mode;
		
		RETURN n;
	END
$$
LANGUAGE plpgsql;

-- This function returns the number of shared, or unshared bathroom 
-- (according to the input) for a specific bnb_band
CREATE OR REPLACE FUNCTION count_bath_shared(bath_shared BOOLEAN, bnb_band VARCHAR(50))
RETURNS INTEGER AS
$$
	DECLARE n INTEGER;
	
	BEGIN
		CREATE TEMPORARY TABLE IF NOT EXISTS temp_mode AS (
			SELECT rr.id, sru.rate
			FROM room_configurations rc, rental_resumes rr, significant_rental_units sru 
			WHERE rc.id = rr.room_configuration AND sru.id = rr.rental_unit AND
				  rc.is_bath_shared = bath_shared
		);

		RETURN count_by_rate_bands(bnb_band);
	END
$$ 
LANGUAGE plpgsql;

-- This function returns the number of specific room_types 
-- (according to the input) for a specific bnb_band
CREATE OR REPLACE FUNCTION count_room_type(room_type VARCHAR(50), bnb_band VARCHAR(50))
RETURNS INTEGER AS
$$
	DECLARE n INTEGER;
	
	BEGIN
		CREATE TEMPORARY TABLE IF NOT EXISTS temp_mode AS (
			SELECT rr.id, sru.rate
			FROM room_configurations rc, rental_resumes rr, significant_rental_units sru 
			WHERE rc.id = rr.room_configuration AND sru.id = rr.rental_unit AND rc.room_type = $1
		);
		
		RETURN count_by_rate_bands(bnb_band);
	END
$$ 
LANGUAGE plpgsql;

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

-- Use a common table expression to find the ideal rental unit for every band rate
WITH ideal_rental_unit_per_rate AS (
	SELECT rate, 
	       ROUND(AVG(rf.price), 2) AS avg_price, 
		   CAST(AVG(n_beds) AS INTEGER) AS n_beds, CAST(AVG(n_baths) AS INTEGER) AS n_baths, 
		   ROUND(AVG(sru.availability_rate_365), 2) AS avg_availability_rate_365,
		   add_band_to_rental_unit_rate(rate) AS rental_unit_band
	FROM significant_rental_units sru, rental_fares rf, room_configurations rc, rental_resumes rr
	WHERE sru.id = rr.rental_unit AND rf.id = rr.rental_fare AND rc.id = rr.room_configuration
	GROUP BY rate
	ORDER BY rate DESC
) 
SELECT  rental_unit_band,
		ROUND(AVG(avg_price), 2) AS avg_price,
		CAST(AVG(n_beds) AS INTEGER) AS avg_number_of_beds, 
		CAST(AVG(n_baths) AS INTEGER) AS avg_number_of_baths, 
      	ROUND(AVG(avg_availability_rate_365), 2) AS avg_availability_rate_365,
		count_bath_shared(TRUE, rental_unit_band) >= count_bath_shared(FALSE, rental_unit_band) AS mode_bath_shared,
		CASE 
			WHEN (count_room_type('Bedroom', rental_unit_band) >= count_room_type('Studio', rental_unit_band)) = TRUE THEN 'Bedroom'
			WHEN (count_room_type('Bedroom', rental_unit_band) >= count_room_type('Studio', rental_unit_band)) = FALSE THEN 'Studio'
		END AS mode_room_type
FROM ideal_rental_unit_per_rate irupr
GROUP BY rental_unit_band;