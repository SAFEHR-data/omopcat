# PRODUCED FOR A SPECIFIC DATASET:
# synthea-allergies-10k
# (but could work for others)

cli::cli_h1("Inserting dummy tables")

dir <- Sys.getenv("EUNOMIA_DATA_FOLDER")
name <- Sys.getenv("TEST_DB_NAME")
version <- Sys.getenv("TEST_DB_OMOP_VERSION")

# Connect to the duckdb test database
con <- DBI::dbConnect(
  duckdb::duckdb(dbdir = glue::glue("{dir}/{name}_{version}_1.0.duckdb"))
)

withr::defer(DBI::dbDisconnect(con))

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
    overwrite = TRUE
  )
}

## Load dummy data and write tables to database
dummy_measurements <- read.csv(here::here("dev/test_db/dummy/measurement.csv"))
write_table(dummy_measurements, con, "measurement")

dummy_observations <- read.csv(here::here("dev/test_db/dummy/observation.csv"))
write_table(dummy_observations, con, "observation")

# Sanity check: read the data back and make sure its consistent
db_measurements <- DBI::dbReadTable(con, "measurement")
stopifnot(all.equal(db_measurements, dummy_measurements))

db_observations <- DBI::dbReadTable(con, "observation")
stopifnot(all.equal(db_observations, dummy_observations))

# Load the CMD object to verify integrity of the schema after insertions
cdm <- CDMConnector::cdm_from_con(
  con = con,
  cdm_schema = Sys.getenv("TEST_DB_CDM_SCHEMA"),
  write_schema = Sys.getenv("TEST_DB_RESULTS_SCHEMA"),
  cdm_name = name
)

cli::cli_alert_success("Dummy tables inserted successfully")
