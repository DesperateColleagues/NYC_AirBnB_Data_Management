SELECT * FROM parks;

SELECT b.neighborood, tp.signname, tp.typecatego, tp.perimeter 
FROM parks tp, boundaries b 
WHERE St_Intersects(tp.perimeter, b.geom);

SELECT tp.gid, COUNT(*) as N
FROM parks tp, boundaries b 
WHERE St_Intersects(tp.geom, b.geom)
GROUP BY tp.gid
ORDER BY N desc;

SELECT tp.gid, tp.signname, b.neighborood, tp.typecatego, tp.geom
FROM parks tp, boundaries b 
WHERE St_Intersects(tp.geom, b.geom) AND tp.gid = 630;

DROP VIEW temp_parks;
	