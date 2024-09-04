cli::cli_h1("Setting up test database")

library(calypso)

# Create an duckdb database from Eunomia datasets
db_path <-  CDMConnector::eunomia_dir(
  dataset_name = Sys.getenv("TEST_DB_NAME"),
  cdm_version = Sys.getenv("TEST_DB_OMOP_VERSION"),
  database_file = tempfile(fileext = ".duckdb")
)

con <- connect_to_db(db_path)

# Use 'cdm_from_con' to load the dataset and verify integrity
CDMConnector::cdm_from_con(
  con = con,
  cdm_schema = Sys.getenv("TEST_DB_CDM_SCHEMA"),
  write_schema = Sys.getenv("TEST_DB_RESULTS_SCHEMA"),
  cdm_name = Sys.getenv("TEST_DB_NAME")
)

cli::cli_alert_success("Test database setup successfully")
