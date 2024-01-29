-- Map crimes description with its key, descriptions are unique hence
-- this operation is legit
UPDATE crimes
SET crime_type = (SELECT id 
				  FROM crime_types 
				  WHERE description = crime_type)
				  
-- Cast the column back to integer
ALTER TABLE crimes ALTER COLUMN crime_type TYPE INTEGER USING crime_type::INTEGER;