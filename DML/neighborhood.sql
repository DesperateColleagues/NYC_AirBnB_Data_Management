-- 1) Rename columns to match schema names
ALTER TABLE neighborhoods RENAME COLUMN gid TO id;
ALTER TABLE neighborhoods RENAME COLUMN ntaname TO name;
ALTER TABLE neighborhoods RENAME COLUMN boroname TO borough;
ALTER TABLE neighborhoods RENAME COLUMN geom TO perimeter;

ALTER TABLE neighborhoods 
	DROP COLUMN borocode, DROP COLUMN countyfips,
	DROP COLUMN nta2020, DROP COLUMN ntaabbrev,
	DROP COLUMN cdta2020, DROP COLUMN ntatype, 
	DROP COLUMN shape_leng, DROP COLUMN shape_area, 
	DROP COLUMN cdtaname;

-- 2) Turn the invalid geometries to valid ones
UPDATE neighborhoods 
SET perimeter = ST_MakeValid(perimeter)
WHERE St_IsValid(perimeter) = 'False';

-- 3) Change perimeter column type in its text form
-- TODO: establish if this procedure is really needed
/*
ALTER TABLE neighborhoods ADD COLUMN perimeter_text text;

UPDATE neighborhoods
SET perimeter_text = ST_AsText(perimeter);

ALTER TABLE neighborhoods DROP COLUMN perimeter;
ALTER TABLE neighborhoods RENAME COLUMN perimeter_text TO perimeter;
*/

-- 4) Replace the name of the borough with its code (it will be FK key)
UPDATE neighborhoods
SET borough = boro_code_from_name(borough);