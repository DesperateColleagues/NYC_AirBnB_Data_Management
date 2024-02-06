-- bnb_house with a number of reviews higher then 50
CREATE VIEW significant_bnb_houses AS (
	SELECT id, name, rate, number_of_reviews
	FROM bnb_houses
	WHERE number_of_reviews > 50 AND rate BETWEEN 3.8 and 5
	ORDER BY rate DESC, number_of_reviews DESC
);

SELECT * FROM significant_bnb_houses;

-- This view holds all the actual fares, since during time a single 
-- bnb_house can have different fares for its rooms.
CREATE VIEW actual_room_fares AS (
	SELECT * 
	FROM room_fares rf1
	WHERE rf1.id IN(SELECT rf2.id
					FROM room_fares rf2 
				    GROUP BY rf2.room_unit, rf2.id
				    HAVING rf2.fare_date = MAX(rf2.fare_date))
);

SELECT * FROM actual_room_fares;

SELECT count (*) as n 
FROM bnb_houses b, room_units ru, actual_room_fares arf
WHERE b.id = ru.bnb_house AND 
      arf.room_unit = ru.id AND 
	  license = false AND 
	  minimum_nights >= 30;

CREATE OR REPLACE FUNCTION count_compliaces(is_compliant BOOLEAN)
RETURNS INTEGER AS
$$
	DECLARE comp_count;
	
	BEGIN 
		CREATE TEMPORARY TABLE no_licenses_bnb AS (
   			SELECT b.id, ru. 
			FROM bnb_houses b, room_units ru, actual_room_fares arf
			WHERE b.id = ru.bnb_house AND 
                  arf.room_unit = ru.id AND 
	              license = false AND 
		);
		
		IF is_compliant THEN SELECT count(*) INTO comp_count 
							 FROM no_licenses_bnb 
							 WHERE 
	END
$$
LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION count_bath_shared(bath_shared BOOLEAN, bnb_rate DECIMAL)
RETURNS INTEGER AS
$$
	SELECT COUNT(*)
	FROM rents r, significant_bnb_houses sb 
	WHERE r.bnb_house = sb.id AND r.is_bath_shared = bath_shared AND sb.rate = bnb_rate
$$ 
LANGUAGE SQL;