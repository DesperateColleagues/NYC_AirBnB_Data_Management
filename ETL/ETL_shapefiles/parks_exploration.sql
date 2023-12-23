CREATE VIEW temp_parks AS (
	SELECT * 
	FROM parks 
	WHERE typecatego NOT IN ('Strip', 'Lot', 'Parkway', 'Cemetery', 
							 'Waterfront Facility', 'Undeveloped', 'Mall')
);

SELECT * FROM temp_parks;

SELECT b.neighborood, tp.signname, tp.typecatego, tp.geom 
FROM temp_parks tp, boundaries b 
WHERE St_Intersects(tp.geom, b.geom);

SELECT tp.gid, COUNT(*) as N
FROM temp_parks tp, boundaries b 
WHERE St_Intersects(tp.geom, b.geom)
GROUP BY tp.gid
ORDER BY N desc;

SELECT tp.gid, tp.signname, b.neighborood, tp.typecatego, tp.geom
FROM temp_parks tp, boundaries b 
WHERE St_Intersects(tp.geom, b.geom) AND tp.gid = 630;

DROP VIEW temp_parks;
	