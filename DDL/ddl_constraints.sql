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
	ADD CONSTRAINT pk_crimes PRIMARY KEY(id);

-- Constraints for "arrests" table
ALTER TABLE arrests
	ADD CONSTRAINT pk_arrests PRIMARY KEY(id),
	ADD CONSTRAINT fk_arrest_crime FOREIGN KEY(crime) REFERENCES crimes(id)
		ON DELETE CASCADE ON UPDATE CASCADE,
	ADD CONSTRAINT fk_crimes_neighborhood FOREIGN KEY(neighborhood) REFERENCES neighborhoods(id)
		ON DELETE CASCADE ON UPDATE CASCADE;
		
-- Constraints for "hosts" table 
ALTER TABLE hosts 
	ADD CONSTRAINT pk_hosts PRIMARY KEY(id);
	
-- Constraints for "rental_units" table
ALTER TABLE rental_units 
	ADD CONSTRAINT pk_rental_units PRIMARY KEY(id),
	ADD CONSTRAINT fk_rental_units_hosts FOREIGN KEY(host) REFERENCES hosts(id)
		ON DELETE CASCADE ON UPDATE CASCADE,
	ADD CONSTRAINT fk_rental_units_neighborhoods FOREIGN KEY(neighborhood) REFERENCES neighborhoods(id)
		ON DELETE CASCADE ON UPDATE CASCADE;

-- Constraints for "room_configurations" table
ALTER TABLE room_configurations
	ADD CONSTRAINT pk_room_configurations PRIMARY KEY(id);

-- Constraints for "rental_fare" table
ALTER TABLE rental_fares
	ADD CONSTRAINT pk_rent_fares PRIMARY KEY(id);
	
-- Constraints for "rental_resumes" table
ALTER TABLE rental_resumes
	ADD CONSTRAINT pk_rental_resume PRIMARY KEY(id),
	ADD CONSTRAINT fk_rental_resume_rental_units FOREIGN KEY(rental_unit) REFERENCES rental_units(id)
		ON DELETE CASCADE ON UPDATE CASCADE,
	ADD CONSTRAINT fk_rental_resume_room_configuration FOREIGN KEY(room_configuration) REFERENCES room_configurations(id)
		ON DELETE CASCADE ON UPDATE CASCADE, 
	ADD CONSTRAINT fk_rental_resume_rental_fare FOREIGN KEY(rental_fare) REFERENCES rental_fares(id)
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
	
-- Constraints for "positionings" table
ALTER TABLE positionings
	ADD CONSTRAINT pk_positionings PRIMARY KEY(borough, park),
	ADD CONSTRAINT fk_positionings_borough FOREIGN KEY(borough) REFERENCES boroughs(id)
		ON DELETE CASCADE ON UPDATE CASCADE,
	ADD CONSTRAINT fk_positionings_park FOREIGN KEY(park) REFERENCES parks(id)
		ON DELETE CASCADE ON UPDATE CASCADE;

-- Constraints for "bus_stops" table
ALTER TABLE bus_stops
	ADD CONSTRAINT pk_bus_stops PRIMARY KEY(id),
	ADD CONSTRAINT fk_bus_stops_neighborhood FOREIGN KEY(neighborhood) REFERENCES neighborhoods(id)
		ON DELETE CASCADE ON UPDATE CASCADE;

-- Constraints for "roads" table
ALTER TABLE roads
	ADD CONSTRAINT pk_roads PRIMARY KEY(id),
	ADD CONSTRAINT fk_roads_borough FOREIGN KEY(borough) REFERENCES boroughs(id);