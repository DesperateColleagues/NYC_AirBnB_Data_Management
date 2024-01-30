-- Constraints for "boroughs" table
ALTER TABLE boroughs 
	ADD CONSTRAINT pk_borough PRIMARY KEY(id);

-- Constraints for "neighborhoods" table
ALTER TABLE neighborhoods 
	ADD CONSTRAINT pk_neighborhoods PRIMARY KEY(id),
	ADD CONSTRAINT fk_neighborhoods_borough FOREIGN KEY(borough) REFERENCES boroughs(id) 
		ON DELETE CASCADE ON UPDATE CASCADE;

-- Constraints for "crimes" table
ALTER TABLE crimes
	ADD CONSTRAINT fk_crimes_crime_type FOREIGN KEY(crime_type) REFERENCES crime_types(id)
		ON DELETE CASCADE ON UPDATE CASCADE,
	ADD CONSTRAINT fk_crimes_neighborhood FOREIGN KEY(neighborhood) REFERENCES neighborhoods(id)
		ON DELETE CASCADE ON UPDATE CASCADE;
		
-- Constraints for "hosts" table 
ALTER TABLE hosts 
	ADD CONSTRAINT pk_hosts PRIMARY KEY(id);
	
-- Constraints for "bnb_house" table
ALTER TABLE bnb_houses 
	ADD CONSTRAINT pk_bnb_houses PRIMARY KEY(id),
	ADD CONSTRAINT fk_bnb_houses_hosts FOREIGN KEY(host) REFERENCES hosts(id)
		ON DELETE CASCADE ON UPDATE CASCADE,
	ADD CONSTRAINT fk_bnb_houses_neighborhoods FOREIGN KEY(neighborhood) REFERENCES neighborhoods(id)
		ON DELETE CASCADE ON UPDATE CASCADE;

-- Constraints for "rent" table
ALTER TABLE rents 
	ADD CONSTRAINT pk_rent PRIMARY KEY(id),
	ADD CONSTRAINT fk_rent_bnb_house FOREIGN KEY(bnb_house) REFERENCES bnb_houses(id)
		ON DELETE CASCADE ON UPDATE CASCADE;

-- Constraints for "rent_fare" table
ALTER TABLE rent_fares
	ADD CONSTRAINT pk_rent_fare PRIMARY KEY(id),
	ADD CONSTRAINT fk_rent_fare_rent FOREIGN KEY(rent) REFERENCES rents(id)
		ON DELETE CASCADE ON UPDATE CASCADE;

-- Constraints for "house_sales" table
ALTER TABLE house_sales
	ADD CONSTRAINT pk_house_sales PRIMARY KEY(id),
	ADD CONSTRAINT fk_house_sale_neighborhood FOREIGN KEY(neighborhood) REFERENCES neighborhoods(id)
		ON DELETE CASCADE ON UPDATE CASCADE;

-- Constraints for "subway_stops" table
ALTER TABLE subway_stops
	ADD CONSTRAINT pk_subway_stops PRIMARY KEY(id),
	ADD CONSTRAINT fk_subway_stops_neighborhood FOREIGN KEY(neighborhood) REFERENCES neighborhoods(id)
		ON DELETE CASCADE ON UPDATE CASCADE;

-- Constraints for "poi_type" table
ALTER TABLE poi_types
	ADD CONSTRAINT pk_poi_types PRIMARY KEY(id);

-- Constraints for "poi" table
ALTER TABLE poi
	ADD CONSTRAINT pk_poi PRIMARY KEY(id),
	ADD CONSTRAINT fk_poi_poi_type FOREIGN KEY(poi_type) REFERENCES poi_types(id)
		ON DELETE CASCADE ON UPDATE CASCADE,
	ADD CONSTRAINT fk_poi_neighborhood FOREIGN KEY(neighborhood) REFERENCES neighborhoods(id)
		ON DELETE CASCADE ON UPDATE CASCADE;

-- Constraints for "parks" table
ALTER TABLE parks
	ADD CONSTRAINT pk_parks PRIMARY KEY(id);

-- Constraints for "bus_stops" table
ALTER TABLE bus_stops
	ADD CONSTRAINT pk_bus_stops PRIMARY KEY(id),
	ADD CONSTRAINT fk_bus_stops_neighborhood FOREIGN KEY(neighborhood) REFERENCES neighborhoods(id)
		ON DELETE CASCADE ON UPDATE CASCADE;

-- Constraints for "roads" table
ALTER TABLE roads
	ADD CONSTRAINT pk_roads PRIMARY KEY(id),
	ADD CONSTRAINT fk_roads_borough FOREIGN KEY(borough) REFERENCES boroughs(id);