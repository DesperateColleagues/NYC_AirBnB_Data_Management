CREATE OR REPLACE FUNCTION ideal_room_configuration(inf DECIMAL, sup DECIMAL)
RETURNS INTEGER AS
$$
	DECLARE n INTEGER;
	
	BEGIN
		WITH t AS(
			SELECT rc.id AS id, COUNT(rc.id) AS tot_use
			FROM room_configurations rc, rental_resumes rs, rental_units ru
			WHERE rc.id = rs.room_configuration AND ru.id = rs.rental_unit AND ru.rate BETWEEN inf AND sup
			GROUP BY rc.id
		) SELECT id INTO n
			FROM t
			WHERE tot_use = (SELECT MAX(tot_use) FROM t)
			LIMIT 1;
		
		RETURN n;
	END
$$ 
LANGUAGE plpgsql;

SELECT ideal_room_configuration(4.10, 4.49);
