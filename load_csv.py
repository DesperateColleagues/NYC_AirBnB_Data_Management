import os
import psycopg2

pwd = 'root' # change password according to your local server

# Define postgres connection
conn = psycopg2.connect (
    database='airbnb', 
    user='postgres', password=pwd,  
    host='127.0.0.1', port='5432'
)

# Get the cursor
conn.autocommit = True
cursor = conn.cursor() 

OUT_FOLDER_PATH = 'ETL/out/'

full_paths = [
        os.path.abspath(os.path.join(OUT_FOLDER_PATH, file)) 
        for file in os.listdir(OUT_FOLDER_PATH)
] 

table_names = [
    'house_sales_temp',
    'listings',
    'nypd_Arrests',
    'subway_stops_temp'
]

for i, table in enumerate(table_names):
    with open( full_paths[i], 'r') as f:
        cursor.copy_expert(f'COPY {table} FROM STDIN WITH HEADER CSV', f)