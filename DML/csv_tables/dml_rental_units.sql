-- Turn the rate into percentage
UPDATE rental_units
SET availability_rate_365 = ROUND(availability_rate_365::DECIMAL/365, 2);

-- Turn the license into boolean value
UPDATE rental_units
SET new_license = true
WHERE old_license IS NOT NULL;

UPDATE rental_units 
SET availability_rate_365 = (SELECT ROUND(AVG(availability_rate_365), 2) 
							 FROM rental_units 
							 WHERE availability_rate_365 <> 0)
WHERE availability_rate_365 = 0; -- unknown

SELECT * FROM rental_units;

ALTER TABLE rental_units DROP old_license;
ALTER TABLE rental_units RENAME COLUMN new_license TO license;
