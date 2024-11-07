# Creates a test database from the synthea-allergies-10k example dataset
# with added dummy data for observations and measurements

# PRODUCED FOR A SPECIFIC DATASET:
# synthea-allergies-10k
# (but could work for others)


# Setup ---------------------------------------------------------------------------------------

library(readr)

here::i_am("data-raw/test_db/create_test_db.R")

dir <- here::here("data-raw/test_db/eunomia")
name <- "synthea-allergies-10k"
version <- "5.3"

Sys.setenv(EUNOMIA_DATA_FOLDER = dir)

db_path <- CDMConnector::eunomia_dir(
  dataset_name = name,
  cdm_version = version,
  database_file = glue::glue("{dir}/{name}_{version}_1.0.duckdb")
)

con <- DBI::dbConnect(duckdb::duckdb(db_path))
withr::defer(DBI::dbDisconnect(con))


# Insert dummy tables -------------------------------------------------------------------------

#' Write data to a table in the database
#'
#' @param data data.frame, data to be written to the table
#' @param con A [`DBI::DBIConnection-class`] object
#' @param table character, name of the table to write to
#' @param schema character, name of the schema to be used
#'
#' @return `TRUE`, invisibly, if the operation was successful
write_table <- function(data, con, table, schema) {
  DBI::dbWriteTable(
    conn = con,
    name = DBI::Id(schema = schema, table = table),
    value = data,
    overwrite = TRUE
  )
}


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
write_table(dummy_measurements, con, "measurement", schema = "main")

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
write_table(dummy_observations, con, "observation", schema = "main")

cli::cli_alert_success("Test database set up successfully")
