# PRODUCED FOR A SPECIFIC DATASET:
# synthea-allergies-10k
# (but could work for others)

cli::cli_h1("Inserting dummy tables")


# Setup ---------------------------------------------------------------------------------------

library(readr)
library(omopcat)

dir <- Sys.getenv("EUNOMIA_DATA_FOLDER")
name <- Sys.getenv("TEST_DB_NAME")
version <- Sys.getenv("TEST_DB_OMOP_VERSION")

db_path <- glue::glue("{dir}/{name}_{version}_1.0.duckdb")

con <- connect_to_db(db_path)


# Insert dummy tables -------------------------------------------------------------------------

## Load dummy data and write tables to database
## We explicitly set the column types for columns that are needed later down the pipeline
dummy_measurements <- read_csv(
  here::here("data-raw/test_db/dummy/measurement.csv"),
  col_types = cols(
    measurement_id = col_integer(),
    person_id = col_integer(),
    measurement_concept_id = col_integer(),
    measurement_date = col_date(),
    value_as_number = col_double(),
    value_as_concept_id = col_integer(),
  )
)
write_table(dummy_measurements, con, "measurement", schema = Sys.getenv("TEST_DB_CDM_SCHEMA"))

dummy_observations <- read_csv(
  here::here(
    "data-raw/test_db/dummy/observation.csv"
  ),
  col_types = cols(
    observation_id = col_integer(),
    person_id = col_integer(),
    observation_concept_id = col_integer(),
    observation_date = col_date(),
    value_as_number = col_double(),
    value_as_string = col_logical(),
    value_as_concept_id = col_integer(),
  )
)
write_table(dummy_observations, con, "observation", schema = Sys.getenv("TEST_DB_CDM_SCHEMA"))

# Sanity check: read the data back and make sure its consistent
db_measurements <- DBI::dbReadTable(con, "measurement")
stopifnot(all.equal(db_measurements, as.data.frame(dummy_measurements)))

db_observations <- DBI::dbReadTable(con, "observation")
stopifnot(all.equal(db_observations, as.data.frame(dummy_observations)))

# Load the CMD object to verify integrity of the schema after insertions
cdm <- CDMConnector::cdm_from_con(
  con = con,
  cdm_schema = Sys.getenv("TEST_DB_CDM_SCHEMA"),
  write_schema = Sys.getenv("TEST_DB_RESULTS_SCHEMA"),
  cdm_name = name
)

cli::cli_alert_success("Dummy tables inserted successfully")
