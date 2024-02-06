-- Find the number for each bedroom
CREATE OR REPLACE FUNCTION find_n_room ()
RETURNS VOID AS
$$ BEGIN
	FOR i IN 1..26 LOOP
    	UPDATE room_configurations
		SET n_rooms = I
		WHERE room_type LIKE Concat(i::VARCHAR,' %');
   END LOOP;
	
END $$
LANGUAGE plpgsql;

SELECT find_n_room();

-- Replace the value without the number
CREATE OR REPLACE FUNCTION update_room_type()
RETURNS VOID AS
$$
BEGIN
	
	UPDATE room_configurations
	SET room_type = 'Bedroom'
	WHERE n_roomS = 1;
	
	UPDATE room_configurations
	SET room_type = 'Bedrooms'
	WHERE n_rooms> 1;
	
END
$$ LANGUAGE plpgsql;

SELECT update_room_type();


UPDATE room_configurations
SET n_baths = 1
WHERE n_baths ISNULL AND is_bath_shared = true;

UPDATE room_configurations
SET is_bath_shared = NULL
WHERE n_baths ISNULL AND is_bath_shared = false;