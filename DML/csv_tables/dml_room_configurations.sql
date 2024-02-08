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

UPDATE room_configurations
SET room_type = 'Bedroom'
WHERE n_rooms IS NOT NULL;

UPDATE room_configurations
SET n_rooms = 1
WHERE room_type LIKE 'Studio';

SELECT DISTINCT room_type FROM room_configurations;