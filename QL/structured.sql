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
CREATE VIEW significant_rental_units AS (
	SELECT id, name, rate, number_of_reviews
	FROM rental_units
	WHERE number_of_reviews > 50 AND rate BETWEEN 3.5 and 5
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
	   
-- market analysis TODO?

/*
	Q3 
	Find the ideal rental unit, by aggregating data like price, number of beds and bathroo 
    and if the bath is shared or not (since it's a categorical feature the mode can be used to aggregate)
*/

-- This function is used to count the mode of bath shared (according to the input parameter) 
-- through a specific rate (input) 
CREATE OR REPLACE FUNCTION count_bath_shared(bath_shared BOOLEAN, bnb_rate DECIMAL)
RETURNS INTEGER AS
$$
	SELECT COUNT(*)
	FROM room_configurations rc, rental_resumes rr, significant_rental_units sru 
	WHERE rc.id = rr.room_configuration AND sru.id = rr.rental_unit AND
	      rc.is_bath_shared = bath_shared AND sru.rate = bnb_rate
$$ 
LANGUAGE SQL;

SELECT rate, AVG(rf.price) AS avg_price, 
       CAST(AVG(n_beds) AS INTEGER) AS n_beds, CAST(AVG(n_baths) AS INTEGER) AS n_baths, 
	   count_bath_shared(TRUE, rate) >= count_bath_shared(FALSE, rate) AS is_bath_shared                                      
FROM significant_rental_units sru, rental_fares rf, room_configurations rc, rental_resumes rr
WHERE sru.id = rr.rental_unit AND rf.id = rr.rental_fare AND rc.id = rr.room_configuration
GROUP BY rate
ORDER BY rate DESC;