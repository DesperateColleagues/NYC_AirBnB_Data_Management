-- 1) Rename columns to match schema names
ALTER TABLE neighborhoods RENAME COLUMN gid TO id;
ALTER TABLE neighborhoods RENAME COLUMN ntaname TO name;
ALTER TABLE neighborhoods RENAME COLUMN boroname TO borough;
ALTER TABLE neighborhoods RENAME COLUMN geom TO perimeter;

CREATE TABLE neighborhoods_new AS (
	SELECT id, name, borough, perimeter 
	FROM neighborhoods
);

DROP TABLE neighborhoods;

ALTER TABLE neighborhoods_new RENAME TO neighborhoods;

-- 2) Turn the invalid geometries to valid ones
UPDATE neighborhoods 
SET perimeter = ST_MakeValid(perimeter)
WHERE St_IsValid(perimeter) = 'False';

-- 4) Replace the name of the borough with its code (it will be FK key)
UPDATE neighborhoods
SET borough = boro_code_from_name(borough);