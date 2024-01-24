-- This function returns the code related to a borough name
CREATE OR REPLACE FUNCTION boro_code_from_name(boro_name VARCHAR(15))
	RETURNS CHAR(2) AS 'SELECT id FROM borough WHERE boro_name = name;'
LANGUAGE SQL;

CREATE OR REPLACE FUNCTION load_csv_data(file_path TEXT, target_table TEXT)
RETURNS VOID AS
$$
BEGIN
    -- Use the COPY command to load data from CSV into the target table
    EXECUTE FORMAT('COPY %I FROM %L WITH CSV HEADER', target_table, file_path);
END;
$$
LANGUAGE plpgsql;
