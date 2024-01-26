-- Constraints for "neighborhoods" table
ALTER TABLE neighborhoods 
	ADD CONSTRAINT pk_neighborhoods PRIMARY KEY(id),
	
	ADD CONSTRAINT fk_neighborhoods_borough FOREIGN KEY(borough) REFERENCES borough(id) 
	ON DELETE CASCADE ON UPDATE CASCADE;

-- Constraints for "crimes" table
ALTER TABLE crimes
	ADD CONSTRAINT fk_crimes_crime_type FOREIGN KEY(crime_types) REFERENCES crime_type(id)
	ON DELETE CASCADE ON UPDATE CASCADE,
	ADD CONSTRAINT fk_crimes_neighborhood FOREIGN KEY(neighborhood) REFERENCES neighborhoods(id)
	ON DELETE CASCADE ON UPDATE CASCADE;
	
-- Constraints for "bnb_house" table
ALTER TABLE bnb_house ADD CONSTRAINT pk_bnb_house PRIMARY KEY(id);
ALTER TABLE bnb_house ADD CONSTRAINT fk_bnb_house_hosts FOREIGN KEY(host) REFERENCES hosts(id);
ALTER TABLE bnb_house ADD CONSTRAINT fk_bnb_house_neighborhoods FOREIGN KEY(neighborhood) REFERENCES neighborhoods(id);

-- Constraints for "rent" table

-- Constraints for "rent_fare" table

-- Constraints fot "house_sales" table

-- Constraints fot "subway_stops" table

-- Constraints fot "poi" table

-- Constraints fot "poi_type" table

-- Constraints fot "parks" table

-- Constraints fot "bus_stops" table

-- Constraints fot "roads" table