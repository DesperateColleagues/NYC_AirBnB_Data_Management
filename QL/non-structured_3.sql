/*
	Q7
									*******CHEAPER SUB AREAS OF THE NEIGHBORHOODS*******
	This query, thanks to the fourth neighborhoods obteined by Q6,  shows for each neighborhood the n sub areas 
	with:
	- significant id
	- geometry
	- average price
	Only sub areas with a average price lower then neighborhood's average price are selected.
*/

-- This function divides each neighborhood specified by its name, into n areas.
-- It returns a table with the sub regions of the specified neighborhood.
CREATE OR REPLACE FUNCTION get_neighborhood_sub_divisions(n_name TEXT, n_sub_perimeters INT)
RETURNS TABLE (neighborhood VARCHAR(100), sub_perimeter geometry) AS 
$$
BEGIN
	RETURN QUERY
		WITH 
			neighborhood AS (
				SELECT * 
				FROM neighborhoods
				WHERE name LIKE n_name
			),
			n_pts AS (
				SELECT (ST_Dump(ST_GeneratePoints(perimeter, n_sub_perimeters * 100, 24))).geom AS geom
				FROM neighborhood
			),
			n_pts_cluster AS (
				SELECT geom, ST_ClusterKMeans(geom, n_sub_perimeters) OVER() AS cluster
				FROM n_pts
			),
			n_cluster_center AS (
				SELECT cluster, ST_Centroid(ST_Collect(geom)) AS geom
				FROM n_pts_cluster
				GROUP BY cluster
			),
			n_voronoi AS (
				SELECT (ST_Dump(ST_VoronoiPolygons(ST_Collect(geom)))).geom AS geom
				FROM n_cluster_center
			)
			SELECT n.name, ST_Intersection(n.perimeter, v.geom) AS sub_perimeter
			FROM neighborhood n CROSS JOIN n_voronoi v;
END;
$$	
LANGUAGE 'plpgsql';

-- Materialize the table obtained by the function
CREATE TEMPORARY TABLE selected_neighborhoods_sub_division AS ( 
	SELECT * FROM get_neighborhood_sub_divisions('Upper East Side-Lenox Hill-Roosevelt Island', 45)
	
	UNION
	
	SELECT * FROM get_neighborhood_sub_divisions('Flatbush (West)-Ditmas Park-Parkville', 40)
	
	UNION
	
	SELECT * FROM get_neighborhood_sub_divisions('Prospect Heights', 35)
	
	UNION
	
	SELECT * FROM get_neighborhood_sub_divisions('Jackson Heights', 45)
);

-- Add an id to this table
ALTER TABLE selected_neighborhoods_sub_division 
	ADD COLUMN sd_id SERIAL PRIMARY KEY;
	
-- Create an index to speed up spatial tables
CREATE INDEX selected_neighborhoods_sub_division_idx
	ON selected_neighborhoods_sub_division
	USING GIST(sub_perimeter);
	
CREATE VIEW sub_perimeters_with_lower_avg_price_per_houses AS (
	WITH 
		avg_price_per_selected_neighborhood AS (
			SELECT n.name AS neighborhood, ROUND(AVG(hs.price), 2) AS avg_price_house_sales, n.perimeter
			FROM neighborhoods n, house_sales hs
			WHERE 	n.name IN ('Upper East Side-Lenox Hill-Roosevelt Island', 'Flatbush (West)-Ditmas Park-Parkville',
							 'Prospect Heights', 'Jackson Heights') AND
					ST_Contains(n.perimeter, hs.coordinates) AND 
					(hs.tax_class LIKE '1%' OR hs.tax_class LIKE '2%') AND 
					hs.price <> 0
			GROUP BY n.name, n.perimeter
		),
		avg_price_per_selected_neighborhood_sub_perimeters AS (
			SELECT 	n.sd_id, ROUND(AVG(hs.price), 2) AS avg_price_house_sales, n.sub_perimeter
			FROM 	selected_neighborhoods_sub_division n, house_sales hs
			WHERE 	ST_Contains(n.sub_perimeter, hs.coordinates) AND
					(hs.tax_class LIKE '1%' OR hs.tax_class LIKE '2%') AND 
					hs.price <> 0				
			GROUP BY n.sd_id, n.sub_perimeter
		)
		SELECT 	avgsp.sd_id, 
				CONCAT(avgsp.sd_id, ') ', avgn.neighborhood, ' (', b.id, ') ') AS vis_id, avgsp.avg_price_house_sales, 
				avgsp.sub_perimeter
		FROM 	avg_price_per_selected_neighborhood_sub_perimeters avgsp, avg_price_per_selected_neighborhood avgn, boroughs b
		WHERE 	ST_Contains(avgn.perimeter, avgsp.sub_perimeter) AND ST_Contains(b.perimeter, avgsp.sub_perimeter) AND
				avgsp.avg_price_house_sales <= avgn.avg_price_house_sales
		ORDER BY avgn.neighborhood, avg_price_house_sales
);

SELECT * 
FROM sub_perimeters_with_lower_avg_price_per_houses;

-- This query shows the square meters of a specific neighborhood's sub areas.
SELECT ST_Area(sub_perimeter::geography)
FROM sub_perimeters_with_lower_avg_price_per_houses
WHERE sd_id = 103;

----------------------------------------------------------------------------------------------------------------------------------------------------
/*
	Q8
									*******TRANSPORT STOPS OF A SUB AREA*******
	This query shows how many bus and subway stops there are in a specific sub area selected from the stakeholder.
*/

CREATE OR REPLACE FUNCTION analyze_sub_neighborhood(id INT)
RETURNS TABLE (vis_id TEXT, n_subway_stops BIGINT, n_bus_stops BIGINT) AS
$$
	BEGIN
		RETURN QUERY
			WITH 
			selected_sub_perimeter AS (
				SELECT * 
				FROM sub_perimeters_with_lower_avg_price_per_houses a
				WHERE a.sd_id = $1
			), 
			selected_sub_perimeter_subway_stops AS(
				SELECT ssp.sd_id, COUNT(*) AS n
				FROM selected_sub_perimeter ssp, subway_stops ss
				WHERE ST_DWithin(ST_Centroid(ssp.sub_perimeter)::geography, ss.coordinates::geography, 1500)
				GROUP BY ssp.sd_id
			),
			selected_sub_perimeter_bus_stops AS (
				SELECT ssp.sd_id, COUNT(*) AS n
				FROM selected_sub_perimeter ssp, bus_stops bs
				WHERE ST_DWithin(ST_Centroid(ssp.sub_perimeter)::geography, bs.coordinates::geography, 1500)
				GROUP BY ssp.sd_id
			)
			SELECT s_perim.vis_id, ss.n AS number_subway_stops, bs.n AS mumber_bus_stops
			FROM selected_sub_perimeter s_perim, selected_sub_perimeter_subway_stops ss, selected_sub_perimeter_bus_stops bs
			WHERE s_perim.sd_id = ss.sd_id AND ss.sd_id = bs.sd_id;
	END;
$$
LANGUAGE 'plpgsql';

SELECT * FROM analyze_sub_neighborhood(103);