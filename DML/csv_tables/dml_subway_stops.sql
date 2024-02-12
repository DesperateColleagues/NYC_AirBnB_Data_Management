-- 0) Insert data into table
INSERT INTO subway_stops (id, name, latitude, longitude)
	SELECT  stop_id, stop_name, stop_lat, stop_lon
	FROM subway_stops_temp;


/* 
   Every subway stop in the imported dataset is differentiated in terms of its id
   in nord and sud, but the relative coordinates are always equals. 
   These duplicates are eliminated 
*/
DELETE 
FROM subway_stops 
WHERE id LIKE '%N' OR id LIKE '%S';