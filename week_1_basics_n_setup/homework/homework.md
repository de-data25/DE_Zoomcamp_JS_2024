## Module 1 Homework

## Docker & SQL

In this homework we'll prepare the environment 
and practice with Docker and SQL


## Question 1. Knowing docker tags

Run the command to get information on Docker 

```docker --help```

Now run the command to get help on the "docker build" command:

```docker build --help```

Do the same for "docker run".

Which tag has the following text? - *Automatically remove the container when it exits* 

- `--delete`
- `--rc`
- `--rmc`
- `--rm`

Answer: 

- `--rm`


## Question 2. Understanding docker first run 

Run docker with the python:3.9 image in an interactive mode and the entrypoint of bash.
Now check the python modules that are installed ( use ```pip list``` ). 

What is version of the package *wheel* ?

- 0.42.0
- 1.0.0
- 23.0.1
- 58.1.0


# Prepare Postgres

Run Postgres and load data as shown in the videos

Command:

# from the working directory where docker-compose.yaml is
docker-compose up

We'll use the green taxi trips from September 2019:

```wget https://github.com/DataTalksClub/nyc-tlc-data/releases/download/green/green_tripdata_2019-09.csv.gz```

You will also need the dataset with zones:

```wget https://s3.amazonaws.com/nyc-tlc/misc/taxi+_zone_lookup.csv```

Notes: URL "https://s3.amazonaws.com/nyc-tlc/misc/taxi+_zone_lookup.csv" wasn't available for download so I downloaded from "https://github.com/DataTalksClub/nyc-tlc-data/releases/download/misc/taxi_zone_lookup.csv "


# Create a new ingest script that ingests both files called ingest_data.py, then dockerize it with

$  docker build -t taxi_ingest:v001 .

# Add URLs

URL_1="https://github.com/DataTalksClub/nyc-tlc-data/releases/download/green/green_tripdata_2019-09.csv.gz"
URL_2="https://github.com/DataTalksClub/nyc-tlc-data/releases/download/misc/taxi_zone_lookup.csv"


# Run the dockerized script

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

Download this data and put it into Postgres (with jupyter notebooks or with a pipeline)


## Question 3. Count records 

How many taxi trips were totally made on September 18th 2019?

Tip: started and finished on 2019-09-18. 

Remember that `lpep_pickup_datetime` and `lpep_dropoff_datetime` columns are in the format timestamp (date and hour+min+sec) and not in date.

- 15767
- 15612
- 15859
- 89009

Answer:

SELECT COUNT(*) FROM green_taxi_trips 
WHERE DATE(LPEP_PICKUP_DATETIME) = '2019-09-18' 
AND DATE(LPEP_DROPOFF_DATETIME) = '2019-09-18';

-- 15612

## Question 4. Largest trip for each day

Which was the pick up day with the largest trip distance
Use the pick up time for your calculations.

- 2019-09-18
- 2019-09-16
- 2019-09-26
- 2019-09-21

Answer:

SELECT MAX(TRIP_DISTANCE), DATE(LPEP_PICKUP_DATETIME) AS DATE_PICKUP 
FROM GREEN_TAXI_TRIPS
GROUP BY DATE_PICKUP
ORDER BY MAX(TRIP_DISTANCE) DESC

-- 2019-09-26

## Question 5. Three biggest pick up Boroughs

Consider lpep_pickup_datetime in '2019-09-18' and ignoring Borough has Unknown

Which were the 3 pick up Boroughs that had a sum of total_amount superior to 50000?
 
- "Brooklyn" "Manhattan" "Queens"
- "Bronx" "Brooklyn" "Manhattan"
- "Bronx" "Manhattan" "Queens" 
- "Brooklyn" "Queens" "Staten Island"

Answer:

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


## Question 6. Largest tip

For the passengers picked up in September 2019 in the zone name Astoria which was the drop off zone that had the largest tip?
We want the name of the zone, not the id.

Note: it's not a typo, it's `tip` , not `trip`

- Central Park
- Jamaica
- JFK Airport
- Long Island City/Queens Plaza

Answer:

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


## Terraform

In this section homework we'll prepare the environment by creating resources in GCP with Terraform.

In your VM on GCP/Laptop/GitHub Codespace install Terraform. 
Copy the files from the course repo
[here](https://github.com/DataTalksClub/data-engineering-zoomcamp/tree/main/01-docker-terraform/1_terraform_gcp/terraform) to your VM/Laptop/GitHub Codespace.

Modify the files as necessary to create a GCP Bucket and Big Query Dataset.


## Question 7. Creating Resources

After updating the main.tf and variable.tf files run:

```
terraform apply
```

Paste the output of this command into the homework submission form.


$ terraform apply
var.project
  Your GCP Project ID

  Enter a value: dtc-de-376922


Terraform used the selected providers to generate the following execution
plan. Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # google_bigquery_dataset.dataset will be created
  + resource "google_bigquery_dataset" "dataset" {
      + creation_time              = (known after apply)
      + dataset_id                 = "trips_data_all"
      + default_collation          = (known after apply)
      + delete_contents_on_destroy = false
      + effective_labels           = (known after apply)
      + etag                       = (known after apply)
      + id                         = (known after apply)
      + is_case_insensitive        = (known after apply)
      + last_modified_time         = (known after apply)
      + location                   = "europe-west6"
      + max_time_travel_hours      = (known after apply)
      + project                    = "dtc-de-376922"
      + self_link                  = (known after apply)
      + storage_billing_model      = (known after apply)
      + terraform_labels           = (known after apply)
    }

  # google_storage_bucket.data-lake-bucket will be created
  + resource "google_storage_bucket" "data-lake-bucket" {
      + effective_labels            = (known after apply)
      + force_destroy               = true
      + id                          = (known after apply)
      + location                    = "EUROPE-WEST6"
      + name                        = "dtc_data_lake_dtc-de-376922"
      + project                     = (known after apply)
      + public_access_prevention    = (known after apply)
      + rpo                         = (known after apply)
      + self_link                   = (known after apply)
      + storage_class               = "STANDARD"
      + terraform_labels            = (known after apply)
      + uniform_bucket_level_access = true
      + url                         = (known after apply)

      + lifecycle_rule {
          + action {
              + type = "Delete"
            }
          + condition {
              + age                   = 30
              + matches_prefix        = []
              + matches_storage_class = []
              + matches_suffix        = []
              + with_state            = (known after apply)
            }
        }

      + versioning {
          + enabled = true
        }
    }

Plan: 2 to add, 0 to change, 0 to destroy.

Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: yes

google_bigquery_dataset.dataset: Creating...
google_storage_bucket.data-lake-bucket: Creating...
google_bigquery_dataset.dataset: Creation complete after 2s [id=projects/dtc-de-376922/datasets/trips_data_all]
google_storage_bucket.data-lake-bucket: Creation complete after 2s [id=dtc_data_lake_dtc-de-376922]

Apply complete! Resources: 2 added, 0 changed, 0 destroyed.




## Submitting the solutions

* Form for submitting: https://courses.datatalks.club/de-zoomcamp-2024/homework/hw01
* You can submit your homework multiple times. In this case, only the last submission will be used. 

Deadline: 29 January, 23:00 CET
