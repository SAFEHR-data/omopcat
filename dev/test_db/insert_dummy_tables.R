
# PRODUCED FOR A SPECIFIC DATASET:
# synthea-allergies-10k
# (but could work for others)

library(tidyverse)

dir <- Sys.getenv("EUNOMIA_DATA_FOLDER")
name <- Sys.getenv("TEST_DB_NAME")
version <- Sys.getenv("TEST_DB_OMOP_VERSION")

# Connect to the duckdb test database
con <- DBI::dbConnect(
  duckdb::duckdb(dbdir = glue::glue("{dir}/{name}_{version}_1.0.duckdb"))
)

# Function to write data to a table in the cdm schema
write_table <- function(data, con, table) {
  # Insert data into the specified table
  # (in the cdm schema)
  DBI::dbWriteTable(
    conn = con,
    name = DBI::Id(
      schema = Sys.getenv("TEST_DB_CDM_SCHEMA"),
      table = table
    ),
    value = data,
    append = TRUE,
    overwrite = FALSE
  )
}

read_csv(here::here("dev/test_db/dummy/measurement.csv")) |>
  write_table(con, "measurement")

read_csv(here::here("dev/test_db/dummy/observation.csv")) |>
  write_table(con, "observation")

# Load the CMD object to verify integrity of the schema
# after insertions
CDMConnector::cdm_from_con(
  con = con,
  cdm_schema = Sys.getenv("TEST_DB_CDM_SCHEMA"),
  write_schema = Sys.getenv("TEST_DB_RESULTS_SCHEMA"),
  cdm_name = name
)

