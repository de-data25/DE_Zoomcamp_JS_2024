#!/usr/bin/env python
# coding: utf-8

# Importing necessary libraries
import os
import argparse
import wget
from time import time
import pandas as pd
from sqlalchemy import create_engine

# Main function definition
def main(params):
    """
    Main function to ingest CSV data into PostgreSQL database.
    Parameters are provided via command line arguments.
    """

    # Extracting parameters from the command line arguments
    user = params.user
    password = params.password
    host = params.host 
    port = params.port 
    db = params.db
    table_name_1 = params.table_name_1
    table_name_2 = params.table_name_2
    url_1 = params.url_1
    url_2 = params.url_2
    
    # Determine the filename based on the file type for trips and zones data
    csv_name_1 = 'output_trips.csv.gz' if url_1.endswith('.csv.gz') else 'output_trips.csv'
    csv_name_2 = 'output_zones.csv.gz' if url_2.endswith('.csv.gz') else 'output_zones.csv'

    # Check if files exist and remove them to ensure fresh downloads
    for file_name in [csv_name_1, csv_name_2]:
        if os.path.exists(file_name):
            os.remove(file_name)

    # Download files using wget
    wget.download(url_1, out=csv_name_1)
    wget.download(url_2, out=csv_name_2)

    # Establishing a connection to the PostgreSQL database
    engine = create_engine(f'postgresql://{user}:{password}@{host}:{port}/{db}')

    # Processing and inserting trips data
    print('Inserting trips data into the database')
    ingest_csv_to_db(csv_name_1, table_name_1, engine, is_trip_data=True)

    # Processing and inserting zones data
    print('Inserting zones data into the database')
    ingest_csv_to_db(csv_name_2, table_name_2, engine)

    print('Finished ingesting all data into the PostgreSQL database')


def ingest_csv_to_db(csv_file, table_name, engine, is_trip_data=False):
    """
    Function to ingest data from a CSV file into a specified table in the PostgreSQL database.
    Handles trips data differently by reading in chunks and converting datetime columns.
    """

    # If processing trips data, handle chunk-wise to efficiently manage large files
    if is_trip_data:
        df_iter = pd.read_csv(csv_file, iterator=True, chunksize=100000)

        # Processing the first chunk to create the table structure
        df = next(df_iter)
        convert_datetime_columns(df)
        df.head(n=0).to_sql(name=table_name, con=engine, if_exists='replace')
        df.to_sql(name=table_name, con=engine, if_exists='append')

        # Looping over and processing the remaining chunks
        while True:
            try:
                t_start = time()
                df = next(df_iter)
                convert_datetime_columns(df)
                df.to_sql(name=table_name, con=engine, if_exists='append')
                t_end = time()
                print('Inserted another chunk, took %.3f second' % (t_end - t_start))
            except StopIteration:
                break
    else:
        # For non-trips data, read the whole file and insert
        df = pd.read_csv(csv_file)
        df.to_sql(name=table_name, con=engine, if_exists='replace')


def convert_datetime_columns(df):
    """
    Converts specific columns in a DataFrame to datetime objects.
    Specifically used for 'lpep_pickup_datetime' and 'lpep_dropoff_datetime' columns.
    """
    df.lpep_pickup_datetime = pd.to_datetime(df.lpep_pickup_datetime)
    df.lpep_dropoff_datetime = pd.to_datetime(df.lpep_dropoff_datetime)


# This block allows the script to be run as a standalone program
if __name__ == '__main__':
    # Setting up command line argument parsing
    parser = argparse.ArgumentParser(description='Ingest CSV data to Postgres')

    # Defining expected command line arguments
    parser.add_argument('--user', required=True, help='user name for postgres')
    parser.add_argument('--password', required=True, help='password for postgres')
    parser.add_argument('--host', required=True, help='host for postgres')
    parser.add_argument('--port', required=True, help='port for postgres')
    parser.add_argument('--db', required=True, help='database name for postgres')
    parser.add_argument('--table_name_1', required=True, help='name of the table for trips')
    parser.add_argument('--table_name_2', required=True, help='name of the table for zones')
    parser.add_argument('--url_1', required=True, help='url of the csv file for trips')
    parser.add_argument('--url_2', required=True, help='url of the csv file for zones')

    # Parsing command line arguments
    args = parser.parse_args()

    # Running the main function with the parsed arguments
    main(args)



# Key Points of the Script:
# Command-Line Arguments: The script uses argparse to handle command-line arguments. It requires details like PostgreSQL database credentials and the URL of the CSV file to be downloaded.

# Downloading Files: It uses the wget Python library to download the file. If the file exists, it is first deleted and then re-downloaded to ensure the latest version is used.

# Database Connection: The script uses SQLAlchemy's create_engine to connect to a PostgreSQL database.

# Data Ingestion: The CSV file is read in chunks to manage memory usage efficiently, especially useful for large files. The data is then ingested into the specified PostgreSQL table.

# Date Parsing: It converts specific columns to datetime objects, assuming these columns (tpep_pickup_datetime, tpep_dropoff_datetime) exist in the CSV.

# Looping Through Chunks: The script iterates over the CSV file in chunks, ingesting each chunk into the database until the entire file is processed.

# Performance Tracking: The script tracks and prints the time taken to process and insert each chunk of data.