/*
	Q4
	List all the borough based on the crime rate from the lower to the higher.
*/


WITH total_crimes AS (
	SELECT COUNT(*) AS tot
	FROM crimes
	
)	SELECT b.name AS borough, 
		   ROUND(CAST(COUNT(*) AS DECIMAL) / CAST((SELECT * FROM total_crimes) AS DECIMAL), 2) AS crime_rate
	FROM neighborhoods n, crimes c, boroughs b
	WHERE n.id = c.neighborhood AND b.id = n.borough 
	GROUP BY b.name
	ORDER BY n_crime ASC;
	
/*
	Q5
	
*/

3: Cultural facility
4: Recreational Facility
6: Transportation Facility
7: Commercial
9: Religious Institution
10: Health Services

/*
	Q6
	List all the borough based on the poi, parks, bus and subway stops number.
*/
SELECT b.name AS borough, COUNT(poi) AS POI_number
FROM poi, neighborhoods n, boroughs b
WHERE n.id = poi.neighborhood AND b.id = n.borough AND poi_type IN(3, 4, 6, 7, 9, 10)
GROUP BY b.name
ORDER BY POI_number DESC;