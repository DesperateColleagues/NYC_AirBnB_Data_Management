CREATE OR REPLACE FUNCTION load_csv_data(file_path TEXT, target_table TEXT)
RETURNS VOID AS
$$
BEGIN
    -- Use the COPY command to load data from CSV into the target table
    EXECUTE FORMAT('COPY %I FROM %L WITH CSV HEADER', target_table, file_path);
END;
$$
LANGUAGE plpgsql;


