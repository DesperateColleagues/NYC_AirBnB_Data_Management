/*
	NOTE: attribute's name for these CSV tables are the SAME
	of the relative CSV file, since the loading happens using 
	the CSV header.
*/

-- This table will load CSV data about bnb listings
CREATE TABLE listings (
	id BIGINT,
    name VARCHAR(255),
    host_id INT,
    host_name VARCHAR(255),
    neighbourhood_group VARCHAR(255),
    neighbourhood VARCHAR(255),
    latitude FLOAT,
    longitude FLOAT,
    bnb_type VARCHAR(255),
    price INT,
    minimum_nights INT,
    number_of_reviews INT,
    last_review DATE,
    reviews_per_month FLOAT,
    calculated_host_listings_count INT,
    availability_365 DECIMAL,
    number_of_reviews_ltm INT,
    license VARCHAR(255),
	rate DECIMAL,
	room_type VARCHAR(255),
	n_beds INTEGER,
	n_baths INTEGER,
	is_bath_shared BOOLEAN
);

-- This table will load csv data about arrests in nyc
CREATE TABLE IF NOT EXISTS nypd_Arrests (
    ARREST_KEY INT,
    ARREST_DATE DATE,
    PD_CD INT,
    PD_DESC VARCHAR(255),
    KY_CD FLOAT,
    OFNS_DESC VARCHAR(255),
    LAW_CODE VARCHAR(50),
    LAW_CAT_CD VARCHAR(50),
    ARREST_BORO VARCHAR(50),
    ARREST_PRECINCT INT,
    JURISDICTION_CODE INT,
    AGE_GROUP VARCHAR(50),
    PERP_SEX VARCHAR(50),
    PERP_RACE VARCHAR(50),
    X_COORD_CD INT,
    Y_COORD_CD INT,
    Latitude FLOAT,
    Longitude FLOAT
);

-- This table will load csv data of subways stops in nyc
CREATE TABLE subway_stops (
    stop_id VARCHAR(50),
    stop_code FLOAT,
    stop_name VARCHAR(255),
    stop_desc FLOAT,
    stop_lat FLOAT,
    stop_lon FLOAT,
    zone_id FLOAT,
    stop_url FLOAT,
    location_type INT,
    parent_station VARCHAR(50)
);

CREATE TABLE IF NOT EXISTS house_sales (
    id INT,
    BOROUGH VARCHAR(50),
    NEIGHBORHOOD VARCHAR(255),
    BUILDING_CLASS_CATEGORY VARCHAR(255),
    TAX_CLASS_AT_PRESENT CHAR(2),
    BLOCK INT,
    LOT INT,
    EASEMENT FLOAT,
    BUILDING_CLASS_AT_PRESENT VARCHAR(50),
    ADDRESS VARCHAR(255),
    APARTMENT_NUMBER VARCHAR(50),
    ZIP_CODE FLOAT,
    RESIDENTIAL_UNITS FLOAT,
    COMMERCIAL_UNITS FLOAT,
    TOTAL_UNITS FLOAT,
    LAND_SQUARE_FEET FLOAT,
    GROSS_SQUARE_FEET FLOAT,
    YEAR_BUILT INTEGER,
    TAX_CLASS_AT_TIME_OF_SALE INT,
    BUILDING_CLASS_AT_TIME_OF_SALE VARCHAR(50),
    SALE_PRICE INT,
    SALE_DATE VARCHAR(50),
    TEMP_CORD VARCHAR(50),
    LATITUDE FLOAT,
    LONGITUDE FLOAT
);