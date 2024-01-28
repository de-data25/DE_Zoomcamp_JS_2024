winpty docker run -it -e POSTGRES_USER="root" -e POSTGRES_PASSWORD="root" -e POSTGRES_DB="ny_taxi" -v //c/Users/Jovana/Documents/GitHub/data-engineering-zoomcamp-main/week_1_basics_n_setup/2_docker_sql/ny_taxi_postgres_data:/var/lib/postgresql/data -p 5432:5432 --network=pg-network --name pgdatabase postgres:13

winpty docker run -it -e POSTGRES_USER="root" -e POSTGRES_PASSWORD="root" -e POSTGRES_DB="ny_taxi" -v $(pwd)/ny_taxi_postgres_data:/var/lib/postgresql/data -p 5432:5432 postgres:13

winpty docker run -it -e POSTGRES_USER="root" -e POSTGRES_PASSWORD="root" -e POSTGRES_DB="ny_taxi" -v //c/Users/Jovana/Documents/GitHub/data-engineering-zoomcamp-main/week_1_basics_n_setup/2_docker_sql/ny_taxi_postgres_data:/var/lib/postgresql/data -p 5432:5432 postgres:13

winpty pgcli -h localhost -p 5432 -u root -d ny_taxi

\dt

docker run -it \
    -e POSTGRES_USER="root" \
    -e POSTGRES_PASSWORD="root" \
    -e POSTGRES_DB="ny_taxi" \
    -v $(pwd)/ny_taxi_postgres_data:/var/lib/postgresql/data \
    -p 5432:5432 \
    --network=pg-network \
    --name pg-database \
    postgres:13

docker run -it \
    -e PGADMIN_DEFAULT_EMAIL="admin@admin.com" \
    -e PGADMIN_DEFAULT_PASSWORD="root" \
    -p 8080:80 \
    --network=pg-network \
    --name pgadmin \
    dpage/pgadmin4
    
# Kod koji radi - moze ovako rucno
docker network create pg-network

docker stop pgadmin
docker rm pgadmin
# git bash 1
winpty docker run -it -e POSTGRES_USER="root" -e POSTGRES_PASSWORD="root" -e POSTGRES_DB="ny_taxi" -v //c/Users/Jovana/Documents/GitHub/data-engineering-zoomcamp-main/week_1_basics_n_setup/2_docker_sql/ny_taxi_postgres_data:/var/lib/postgresql/data --network=pg-network --name pg-database -p 5432:5432 postgres:13
# git bash 2
winpty docker run -it -e PGADMIN_DEFAULT_EMAIL="admin@admin.com" -e PGADMIN_DEFAULT_PASSWORD="root" -p 8080:80 --network=pg-network --name pgadmin dpage/pgadmin4

python ingest_data.py \
    --user=root \
    --password=root \
    --host=localhost \
    --port=5432 \
    --db=ny_taxi \
    --table_name=yellow_taxi_trips \
    --url="https://s3.amazonaws.com/nyc-tlc/trip+data/yellow_tripdata_2021-01.csv"


# Nakon toga Python se runuje
python ingest_data.py --user=root --password=root --host=localhost --port=5432 --db=ny_taxi --table_name=yellow_taxi_trips --url="https://github.com/DataTalksClub/nyc-tlc-data/releases/download/yellow/yellow_tripdata_2021-01.csv.gz"

# ili koriscenje docker-compose fajla:

#This docker-compose file defines two services: pgdatabase and pgadmin. 
#Each service uses a Docker image and specifies configuration details. 
#Below is an explanation and comment for each part of the file:

services:
  # Service for PostgreSQL database
  pgdatabase:
    image: postgres:13  # Using the official PostgreSQL image (version 13)
    environment:
      - POSTGRES_USER=root  # Setting the default PostgreSQL user to 'root'
      - POSTGRES_PASSWORD=root  # Setting the default PostgreSQL password to 'root'
      - POSTGRES_DB=ny_taxi  # Creating a default database named 'ny_taxi'
    volumes:
      - "./ny_taxi_postgres_data:/var/lib/postgresql/data:rw"  # Persisting data: maps a local directory to the container's data directory
    ports:
      - "5432:5432"  # Exposing PostgreSQL default port 5432 to the host

  # Service for pgAdmin - a web-based administration tool for PostgreSQL
  pgadmin:
    image: dpage/pgadmin4  # Using the official pgAdmin 4 Docker image
    environment:
      - PGADMIN_DEFAULT_EMAIL=admin@admin.com  # Setting the default email for pgAdmin login
      - PGADMIN_DEFAULT_PASSWORD=root  # Setting the default password for pgAdmin
    volumes:
      - "./data_pgadmin:/var/lib/pgadmin"  # Persisting pgAdmin data: maps a local directory to the pgAdmin data directory
    ports:
      - "8080:80"  # Exposing pgAdmin on port 8080 of the host (mapped to port 80 in the container)

# konvertovanje Jupyter notebook skripte y .py

jupyter nbconvert --to=script upload-data.ipynb

# re-build docker-a nakon izmene
 docker build -t taxi_ingest:v001 .

 # Dockerizing the script - okidamo iz dokera, ubacujemo u mrezu i verzija 2, i host nije localhost nego pgdatabase

 winpty docker run -it --network=2_docker_sql_default taxi_ingest:v001 --user=root --password=root --host=2_docker_sql-pgdatabase-1 --port=5432 --db=ny_taxi --table_name=yellow_taxi_trips --url="https://github.com/DataTalksClub/nyc-tlc-data/releases/download/yellow/yellow_tripdata_2021-01.csv.gz"

 winpty docker run -it --network=pg-network taxi_ingest_test:v001 --user=root --password=root --host=pgdatabase --port=5432 --db=ny_taxi --table_name=yellow_taxi_trips --url="https://github.com/DataTalksClub/nyc-tlc-data/releases/download/yellow/yellow_tripdata_2021-01.csv.gz"


docker run taxi_ingest:v001 --user=root --password=root --host=pgdatabase --port=5432 --db=ny_taxi --table_name=yellow_taxi_trips --url="https://github.com/DataTalksClub/nyc-tlc-data/releases/download/yellow/yellow_tripdata_2021-01.csv.gz"


 docker run taxi_ingest:v001 --user=root --password=root --host=localhost --port=5432 --db=ny_taxi --table_name=yellow_taxi_trips --url="URL"

# docker ps - list of running container
# docker kill brojprocesa
# python -m http.server

docker-compose up
# or
docker-compose up -d

### GCP and Terraform

export GOOGLE_APPLICATION_CREDENTIALS="//c/Users/Jovana/Documents/GitHub/data-engineering-zoomcamp-main/files/dtc-de-376922-150d424d0e43_terraform.json"

export GOOGLE_APPLICATION_CREDENTIALS="//c/Users/Jovana/Documents/GitHub/data-engineering-zoomcamp-main/files/dtc-de-409722-ba2c5237417a_2506.json"
gcloud auth application-default login

"//c/Users/Jovana/Documents/GitHub/data-engineering-zoomcamp/files/dtc-de-376922-150d424d0e43_terraform.json"


```bash
URL="https://github.com/DataTalksClub/nyc-tlc-data/releases/download/yellow/yellow_tripdata_2021-01.csv.gz"

URL_1="https://github.com/DataTalksClub/nyc-tlc-data/releases/download/green/green_tripdata_2019-09.csv.gz"

# URL_2="https://s3.amazonaws.com/nyc-tlc/misc/taxi+_zone_lookup.csv"

URL_2="https://github.com/DataTalksClub/nyc-tlc-data/releases/download/misc/taxi_zone_lookup.csv"


winpty docker run -it \
  --network=2_docker_sql_default \
  taxi_ingest:v001 \
    --user=root \
    --password=root \
    --host=2_docker_sql-pgdatabase-1 \
    --port=5432 \
    --db=ny_taxi \
    --table_name_1=green_taxi_trips \
    --table_name_2=taxi_zone_lookup \
    --url_1=${URL_1} \
    --url_2=${URL_2}

Docker - ingestion when using docker-compose could not translate host name
Typical error: sqlalchemy.exc.OperationalError: (psycopg2.OperationalError) could not translate host name "pgdatabase" to address: Name or service not known

When running docker-compose up -d see which network is created and use this for the ingestions script instead of pg-network and see the name of the database to use instead of pgdatabase

E.g.: 
pg-network becomes 2docker_default
Pgdatabase becomes 2docker-pgdatabase-1


--- Airflow

$ cd ~ && mkdir -p ~/.google/credentials/

$ mv ~/Documents/GitHub/data-engineering-zoomcamp/files/google_credentials.json ~/.google/credentials/google_credentials.json

-- udji u Airflow folder
mkdir -p ./dags ./logs ./plugins
    echo -e "AIRFLOW_UID=$(id -u)" > .env

    AIRFLOW_UID=50000


Question 2:

docker pull python:3.9
docker run -it --entrypoint bash python:3.9

pip list

Package    Version
---------- -------
pip        23.0.1
setuptools 58.1.0
wheel      0.42.0


Question 3. Count records
How many taxi trips were totally made on September 18th 2019?

Tip: started and finished on 2019-09-18.

Remember that lpep_pickup_datetime and lpep_dropoff_datetime columns are in the format timestamp (date and hour+min+sec) and not in date.

-- Question 3. Count records
-- How many taxi trips were totally made on September 18th 2019?

-- Tip: started and finished on 2019-09-18.

-- Remember that lpep_pickup_datetime and lpep_dropoff_datetime columns are in the format timestamp (date and hour+min+sec) and not in date.

SELECT COUNT(*) FROM green_taxi_trips 
WHERE DATE(LPEP_PICKUP_DATETIME) = '2019-09-18' 
AND DATE(LPEP_DROPOFF_DATETIME) = '2019-09-18';

-- 15612

--Question 4. Largest trip for each day
--Which was the pick up day with the largest trip distance Use the pick up time for your calculations.

SELECT MAX(TRIP_DISTANCE), DATE(LPEP_PICKUP_DATETIME) AS DATE_PICKUP 
FROM GREEN_TAXI_TRIPS
GROUP BY DATE_PICKUP
ORDER BY MAX(TRIP_DISTANCE) DESC

-- 2019-09-26


--Question 5. Three biggest pick up Boroughs
--Consider lpep_pickup_datetime in '2019-09-18' and ignoring Borough has Unknown

--Which were the 3 pick up Boroughs that had a sum of total_amount superior to 50000?

SELECT tzl."Borough", SUM(gt.total_amount) AS total_amount_sum
FROM public.green_taxi_trips gt
JOIN public.taxi_zone_lookup tzl ON gt."PULocationID" = tzl."LocationID"
WHERE gt.lpep_pickup_datetime::date = '2019-09-18'
  AND tzl."Borough" != 'Unknown'
GROUP BY tzl."Borough"
HAVING SUM(gt.total_amount) > 50000
ORDER BY total_amount_sum DESC
LIMIT 3;
-- "Brooklyn" "Manhattan" "Queens"


--Question 6. Largest tip
--For the passengers picked up in September 2019 in the zone name Astoria which was the drop off zone that had the largest tip? We want the name of the zone, not the id.

--Note: it's not a typo, it's tip , not trip

SELECT MAX(A.TIP_AMOUNT), 
A.DOLOCATION_ZONE 
FROM (SELECT GTD.TIP_AMOUNT,
	  TXLP."Zone" AS PULOCATION_ZONE, 
	  TXLD."Zone" AS DOLOCATION_ZONE
	  FROM GREEN_TAXI_TRIPS AS GTD 
	  LEFT JOIN TAXI_ZONE_LOOKUP AS TXLP 
	  ON GTD."PULocationID" = TXLP."LocationID" 
	  LEFT JOIN TAXI_ZONE_LOOKUP AS TXLD 
	  ON GTD."DOLocationID" = TXLD."LocationID" 
	  WHERE TXLP."Zone" like 'Astoria%') A 
	  GROUP BY A.DOLOCATION_ZONE 
	  ORDER BY MAX(A.TIP_AMOUNT) 
DESC LIMIT 1;

-- JFK Airport


-- option 2
SELECT dropoff_zone."Zone" AS dropoff_zone_name, MAX(gt.tip_amount) AS max_tip
FROM public.green_taxi_trips gt
JOIN public.taxi_zone_lookup pickup_zone ON gt."PULocationID" = pickup_zone."LocationID"
JOIN public.taxi_zone_lookup dropoff_zone ON gt."DOLocationID" = dropoff_zone."LocationID"
WHERE pickup_zone."Zone" = 'Astoria'
  AND gt.lpep_pickup_datetime >= '2019-09-01' AND gt.lpep_pickup_datetime < '2019-10-01'
GROUP BY dropoff_zone."Zone"
ORDER BY max_tip DESC
LIMIT 1;


Exciting Update from Data Engineering Zoomcamp by DataTalksClub! 🎉

I'm thrilled to share the enriching outcomes from the first module of our Data Engineering Zoomcamp. Here's a glimpse of what we've explored:

Module 1 Highlights:

* Python Programming
* Docker Essentials
* SQL Practice
* Introduction to GCP
* Terraform Techniques

Check out the complete project materials in GitHub Repository.

Special Thanks:
A heartfelt shoutout to Alexey Grigorev and the entire DataTalksClub team for their unwavering support and guidance. 
Your dedication is immensely appreciated.

Next stop: Mage.  🚀

hashtag#dezoomcamp hashtag#dataengineering hashtag#postgres hashtag#docker hashtag#gcp hashtag#terraform hashtag#data hashtag#datatalksclub hashtag#postgresql

https://github.com/de-data25/DE_Zoomcamp_JS_2024.git

https://github.com/DataTalksClub/data-engineering-zoomcamp.git