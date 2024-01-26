-- Map crimes description with its key, descriptions are unique hence
-- this operation is legit
UPDATE crimes
SET crime_type = (SELECT id 
				  FROM crime_types 
				  WHERE description = crime_type)