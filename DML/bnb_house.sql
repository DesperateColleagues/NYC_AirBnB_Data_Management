-- Turn the rate into percentage
UPDATE bnb_houses
SET availability_rate_365 = ROUND(availability_rate_365::DECIMAL/365, 2);
