-- Insert data into table
INSERT INTO crimes(description) 
	SELECT DISTINCT OFNS_DESC
	FROM nypd_arrests;
	
INSERT INTO arrests (id, arrest_date, crime, latitude, longitude)
	SELECT ARREST_KEY, arrest_date, ct.id, latitude, longitude
	FROM nypd_arrests na, crimes ct
	WHERE ct.description = na.OFNS_DESC -- map the description with its id