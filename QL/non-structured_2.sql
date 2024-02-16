SELECT	
FROM	
WHERE	
GROUP BY *PARCO*
ORDER BY *DIMENSIONE PARCO* DESC

select * from parks WHERE name LIKE 'Central Park';

ST_Buffer(ru.coordinates::geography, $1, 'quad_segs=16')::geometry AS circle


CREATE TEMPORARY TABLE Central_Park_decomposition AS (
WITH tbla AS (
	SELECT (ST_ExteriorRing(((ST_Dump(p.perimeter)).geom))) geom FROM parks p WHERE p.name LIKE 'Central Park'), 
	intervals AS (SELECT generate_series (0, 49) as steps) 
	SELECT steps AS stp, 
	ST_LineInterpolatePoint(geom, steps/(SELECT count(steps)::float - 1 FROM intervals)) geom
	FROM tbla, intervals 
	GROUP BY intervals.steps, geom
);

CREATE INDEX Central_Park_decomposition_idx
	ON Central_Park_decomposition
	USING GIST(geom);

CREATE VIEW IF NOT EXISTS nearest_street_from_point AS (
	SELECT roads.id, roads.name, roads.dist
	FROM Central_Park_decomposition cpd
		CROSS JOIN LATERAL (
		SELECT r.*, r.path::geography <-> cpd.geom::geography AS dist
		FROM roads r
		ORDER BY dist
		LIMIT 1
	) AS roads
);

