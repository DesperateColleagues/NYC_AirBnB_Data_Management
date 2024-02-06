-- Turn the rate into percentage
UPDATE rental_units
SET availability_rate_365 = ROUND(availability_rate_365::DECIMAL/365, 2);

-- Turn the license into boolean value
UPDATE rental_units
SET new_license = true
WHERE old_license IS NOT NULL;

ALTER TABLE rental_units DROP old_license;
ALTER TABLE rental_units RENAME COLUMN new_license TO license;
