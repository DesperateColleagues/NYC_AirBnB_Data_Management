/*
	Q final
	
	This query is used to calculate and compare how many year, working 70% of the year, the stakeholder are required to 
	recover his investment in buying the property in the zone number 103 in 'Upper East Side-Lenox Hill-Roosevelt Island (MN)'
	considering:
	- Standard New York City excellent band prices 
	- The excellent band prices in about 1km from the center of the chosen zone 103 (already calculated in spatial Q8)
*/

-- RIT = Recover Invevestment Time
SELECT 	ROUND(s.avg_price_house_sales / (s.avg_price_ex_band * 365 * 0.70), 2) AS RIT_CENTRAL_PARK_ZONE_EXCELLENT,
		ROUND(s.avg_price_house_sales / (ir.avg_price * 365 * 0.70), 2) AS RIT_NYC_GLOBAL_EXCELLENT
FROM 	analyze_sub_neighborhood(103) s, 
		(SELECT	avg_price 
		 FROM 	ideal_rental_unit_per_band_rate ir 
		 WHERE 	rental_unit_band = 'excellent') AS ir;