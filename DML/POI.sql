-- 1) Fill in the "type_desc" column of the "poi_type" table with the currisponding code description

CREATE OR REPLACE FUNCTION Fill_poi_type(varchar[])
RETURNS VOID
AS $$
BEGIN
   for i in 1..array_length($1, 1) loop
    UPDATE poi_type
	SET type_desc = $1[i]
	WHERE id = i;
   end loop;
END $$
LANGUAGE plpgsql;


SELECT Fill_poi_type(ARRAY ['Residential', 
							'Education Facility',
							'Cultural Facility',
							'Recreational Facility',
							'Social Services',
							'Transportation Facility',
							'Commercial',
							'Government Facility (non public safety)',
							'Religious Institution',
							'Health Services',
							'Public Safety',
							'Water',
							'Miscellaneous' ])


-- 2) Update the "domain" column of the "poi" table with the currisponding code description
CREATE OR REPLACE FUNCTION Update_domain_column(data_ varchar[])
RETURNS VOID
AS $$
BEGIN
   for i in 1..array_length(data_, 1) loop
   
   	for j in 1..array_length(data_, 2) loop
	
    UPDATE poi
	SET domain = data_[i][j::INTEGER]
	WHERE poi_type = i AND poi.domain = j::VARCHAR;
	
	end loop;
	
   end loop;
END $$
LANGUAGE plpgsql;



SELECT Update_domain_column(ARRAY [ARRAY ['Gated Development', 'Private Development', 'Public Housing Development', 'Constituent', 'Other', '', '', '', '', '', '', '', '', '', '', '', '', ''],
								   ARRAY ['Public Elementary School', 'Public Junior High-Intermediate-Middle', 'Public High School', 'Private/Parochial Elementary School', 'Private/Parochial Junior/Middle School', 'Private/Parochial High School', 'Post Secondary Degree Granting Institution', 'Other', 'Public Early Childhood', 'Public K-8', 'Public K-12 all grades', 'Public Secondary School', 'Public School Building', 'Public School Annex', 'Private/Parochial Early Childhood', 'Private/Parochial K-8', 'Private/Parochial K-12 all grades', 'Private/Parochial Secondary School'],
								   ARRAY ['Center', 'Library', 'Theater/Concert Hall', 'Museum', 'Other', '', '', '', '', '', '', '', '', '', '', '', '', ''],
								   ARRAY ['Park', 'Amusement Park', 'Golf Course', 'Beach', 'Botanical Garden', 'Zoo', 'Recreational Center', 'Sports', 'Playground', 'Other', 'Pool', 'Garden', '', '', '', '', '', ''],
								   ARRAY ['Residential Child Care', 'Day Care Center', 'Adult Day Care', 'Nursing Home/Assisted Living Facility', 'Homeless shelter', 'Other', '', '', '', '', '', '', '', '', '', '', '', ''],
								   ARRAY ['Bus Terminal', 'Ferry landing/terminal', 'Transit/Maintenance Yard', 'Airport', 'Heliport', 'Marina', 'Pier', 'Bridge', 'Tunnel', 'Exit/Entrance', 'Water Navigation', 'Other', '', '', '', '', '', ''],
								   ARRAY ['Center', 'Business', 'Market', 'Hotel/Motel', 'Restaurant', 'Other', '', '', '', '', '', '', '', '', '', '', '', ''],
								   ARRAY ['Government Office', 'Court of law', 'Post Office', 'Consulate', 'Embassy', 'Military', 'Other', '', '', '', '', '', '', '', '', '', '', ''],
								   ARRAY ['Church', 'Synagogue', 'Temple', 'Convent/Monastery', 'Mosque', 'Other', '', '', '', '', '', '', '', '', '', '', '', ''],
								   ARRAY ['Hospital', 'Inpatient care center', 'Outpatient care center/Clinic', 'Other', '', '', '', '', '', '', '', '', '', '', '', '', '', ''],
								   ARRAY ['NYPD Precinct', 'NYPD Checkpoint', 'FDNY Ladder Company', 'FDNY Battalion', 'Correctional Facility', 'FDNY Engine Company', 'FDNY Special Unit', 'FDNY Division', 'FDNY Squad', 'NYPD Other', 'Other', 'FDNY Other', '', '', '', '', '', ''],
								   ARRAY ['Island', 'River', 'Lake', 'Stream', 'Other', 'Pond', '', '', '', '', '', '', '', '', '', '', '', ''],
								   ARRAY ['Official Landmark', 'Point of Interest', 'Cemetery/Morgue', 'Other', '', '', '', '', '', '', '', '', '', '', '', '', '', '']
								  ])

-- THIS FUNCTION IS A GENERALIZATION OF ALL THE FUNCTION ABOVE
-- CREATE FUNCTION Fill_column_table(data_ varchar[], table_name_ varchar, column_name_ varchar, column_index_ varchar)
-- RETURNS VOID
-- AS $$
-- BEGIN
--    for i in 1..array_length(data_, 1) loop
--     UPDATE table_name_
-- 	SET column_name_ = data_[i]
-- 	WHERE column_index_ = i;
--    end loop;
-- END $$
-- LANGUAGE plpgsql;