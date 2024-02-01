-- Turn the rate into percentage
UPDATE bnb_houses
SET availability_rate_365 = ROUND(availability_rate_365::DECIMAL/365, 2);

-- Turn the license into boolean value
UPDATE bnb_houses
SET new_license = true
WHERE old_license IS NOT NULL;

ALTER TABLE bnb_houses DROP old_license;
ALTER TABLE hosts RENAME COLUMN new_license TO license;
