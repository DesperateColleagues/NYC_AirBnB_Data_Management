/*
	Q7
	For all borough find the houses percentage that were sold with a price lower than borough average price 
*/
WITH avg_price_per_borough AS(
	SELECT b.name AS borough, ROUND(AVG(hs.price), 2) AS avg_price, COUNT(*) AS tot_house
	FROM house_sales hs, neighborhoods n, boroughs b
	WHERE hs.neighborhood = n.id AND n.borough = b.id AND 
		(hs.tax_class LIKE '1%' OR hs.tax_class LIKE '2%') AND hs.price <> 0
	GROUP BY b.name
)
SELECT 	b.name AS borough, 
		(ROUND(CAST(COUNT(*) AS DECIMAL) / 
			   (SELECT tot_house FROM avg_price_per_borough WHERE borough = b.name), 2)) AS house_sold_low_avg,
		CEIL(CAST(AVG(hs.sqft) * 0.092903 AS DECIMAL)) AS avg_sqft
FROM 	house_sales hs, neighborhoods n, boroughs b
WHERE 	hs.neighborhood = n.id AND n.borough = b.id AND
		(hs.tax_class LIKE '1%' OR hs.tax_class LIKE '2%') AND hs.price <> 0 AND
		hs.price < (SELECT avg_price FROM avg_price_per_borough apb WHERE apb.borough = b.name)
GROUP BY b.name
ORDER BY house_sold_low_avg DESC;