# NYC_AirBnB_Data_Management

A data management project that extracts useful information from a dataset of AirBnB New York City hosts.

## Where to find the Datasets

The datasets can be found in the **datasets** folder. A few notes about it:

- **datasets**: contains all the datasets of the project
- **datasets/csv_datasets**: contains the datasets (in csv format) that needs to be cleaned before being used (this operation is performed inside the cleaning folder).
  
| File name            | Description                                                    | Size   |
|----------------------|----------------------------------------------------------------|--------|
| listings.csv         | AirBnB listings in New York city                               | $10^4$ |
| stops.csv            | Subway's stops locations in New York City                      | $10^3$ |
| [district_name].csv  | Data about the house prices in various New York City districts | $10^4$ |
| NYPD_Arrest_2023.csv | Data about arrests and crimes in New York City                 | $10^6$ |

- **datasets/spatial_datasets_zipped**: contains all the spatial datasets. The data are zipped since their dimension is not supported by GitHub.

| File name                     | Description                                                                                          | Size   |
|-------------------------------|------------------------------------------------------------------------------------------------------|--------|
| nyc_borough_boundaries.zip    | Shapefile with New York City neighborhood areas                                                      | $10^2$ |
| nyc_roads.zip                 | Shapefile with road lines in New York City                                                           | $10^3$ |
| nyc_parks.zip                 | Shapefile with New York City parks' areas                                                            | $10^2$ |
| nyc_bus_stops_shelters.zip    | Shapefile with the bus stops locations (points) in New York City                                     | $10^3$ |
| nyc_points_of_Interest.zip    | Shapefile with POI (monuments, schools...) in New York City                                          | $10^5$ |
