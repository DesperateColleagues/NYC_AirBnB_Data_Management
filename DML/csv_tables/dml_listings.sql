/* 
	This function is used to set a license boolean value 
	inside the rental units.
*/
CREATE OR REPLACE FUNCTION set_licence(VARCHAR(255))
RETURNS BOOLEAN AS 
$$
	DECLARE is_licensed BOOLEAN;
	
	BEGIN
		IF $1 IS NOT NULL THEN
			SELECT TRUE INTO is_licensed;
		ELSE 
			SELECT FALSE INTO is_licensed;
		END IF;
		
		RETURN is_licensed;
	END
$$
LANGUAGE plpgsql;

/*
	This function is used to dind the number of rooms 
	for each room configuration
*/
CREATE OR REPLACE FUNCTION find_n_room()
RETURNS VOID AS
$$ BEGIN
	FOR i IN 1..26 LOOP
    	UPDATE room_configurations
		SET n_rooms = I
		WHERE room_type LIKE Concat(CAST(i AS VARCHAR),' %');
   END LOOP;
	
END $$
LANGUAGE plpgsql;
-----------------------------------------------------------------------------------------------------------------

/*
	Insert data into each tables obtained from listings
	1) rental_units
	2) room_configurations
	3) hosts
	4) rental_fares
	5) rental_resumes
*/

-- 1)
INSERT INTO rental_units (id, name, availability_rate_365, rate, 
						 number_of_reviews, latitude, longitude, 
						 host, license) 
	SELECT id, name, availability_365, rate, 
	       number_of_reviews, latitude, longitude, 
		   host_id, set_licence(license)
	FROM listings;
	
-- 2) 
INSERT INTO room_configurations(room_type, n_beds, n_baths, is_bath_shared)
	SELECT room_type, n_beds, n_baths, is_bath_shared
	FROM listings
	GROUP BY room_type, n_beds, n_baths, is_bath_shared;
	
-- 3) 
INSERT INTO hosts (id, name)
	SELECT host_id AS id, host_name AS name
	FROM listings
	WHERE name IS NOT NULL
	GROUP BY host_id, host_name;

-- 4) 
INSERT INTO rental_fares(price, minimum_nights)
	SELECT price, minimum_nights
	FROM listings
	GROUP BY price, minimum_nights;
	
-- 5) 
INSERT INTO rental_resumes(rental_unit, room_configuration, rental_fare, resume_date)
	SELECT l.id AS rental_unit, rg.id AS room_configuration, 
	       rf.id AS rental_fare, CURRENT_DATE AS resume_date
	FROM listings l, room_configurations rg, rental_fares rf
	WHERE l.room_type = rg.room_type AND l.n_beds = rg.n_beds AND 
	      l.n_baths = rg.n_baths AND l.is_bath_shared = rg.is_bath_shared AND 
	      l.price = rf.price AND l.minimum_nights = rf.minimum_nights;
---------------------------------------------------------------------------------------------------------------------
/*
	In this section basic DML operations for rental units and 
	room configurations are exectued
*/

-- Cast the column to decimal with 2 decimal digits
UPDATE rental_units
SET availability_rate_365 = ROUND(
	CAST(availability_rate_365 AS DECIMAL)/365, 2
);

-- Set availability_rate_365 as the avg of this column when
-- the value is zero
UPDATE rental_units 
SET availability_rate_365 = (SELECT ROUND(AVG(availability_rate_365), 2) 
							 FROM rental_units 
							 WHERE availability_rate_365 <> 0)
WHERE availability_rate_365 = 0; -- unknown

-- Find the number of rooms for each room_configuration
SELECT find_n_room();

-- Set the room type to bedroom where the number of rooms is known
-- since, by default, only Studio room have a null n_rooms column
UPDATE room_configurations
SET room_type = 'Bedroom'
WHERE n_rooms IS NOT NULL;

-- Set n_rooms to 1 to Studio rooms
UPDATE room_configurations
SET n_rooms = 1
WHERE room_type LIKE 'Studio';
