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
schema <- "main"

# Download the example data if it doesn't exist yet and create the duckdb database
withr::with_envvar(
  new = c(EUNOMIA_DATA_FOLDER = dir),
  {
    invisible(CDMConnector::eunomiaDir(datasetName = name, cdmVersion = version))
  }
)

con <- DBI::dbConnect(duckdb::duckdb(glue::glue("{dir}/{name}_{version}_1.1.duckdb")))
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
    measurement_time = col_character(),
    measurement_type_concept_id = col_integer(),
    operator_concept_id = col_integer(),
    unit_concept_id = col_integer(),
    range_low = col_number(),
    range_high = col_number(),
    provider_id = col_integer(),
    visit_occurrence_id = col_integer(),
    visit_detail_id = col_integer(),
    measurement_source_value = col_character(),
    measurement_source_concept_id = col_integer(),
    unit_source_value = col_character(),
    value_source_value = col_character()
  )
)
write_table(dummy_measurements, con, "measurement", schema = schema)

dummy_observations <- read_csv(
  here::here("data-raw/test_db/dummy/observation.csv"),
  col_types = cols(
    observation_id = col_integer(),
    person_id = col_integer(),
    observation_concept_id = col_integer(),
    observation_date = col_date(),
    value_as_number = col_double(),
    value_as_string = col_character(),
    value_as_concept_id = col_integer(),
    observation_type_concept_id = col_integer(),
    qualifier_concept_id = col_integer(),
    unit_concept_id = col_integer(),
    provider_id = col_integer(),
    visit_occurrence_id = col_integer(),
    visit_detail_id = col_integer(),
    observation_source_value = col_character(),
    observation_source_concept_id = col_integer(),
    unit_source_value = col_character(),
    qualifier_source_value = col_character()
  )
)
write_table(dummy_observations, con, "observation", schema = schema)

## Verify integrity, turn warnings into error
tryCatch(
  cdm <- CDMConnector::cdmFromCon(con, cdmSchema = schema, writeSchema = schema),
  warning = function(cnd) {
    msg <- sprintf("CDM integrity check produced warnings: %s", conditionMessage(cnd))
    rlang::abort(msg, call = NULL)
  }
)

cli::cli_alert_success("Test database set up successfully")
