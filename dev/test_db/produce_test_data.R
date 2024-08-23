cli::cli_h1("Producing test data")

library(dplyr)

dir <- Sys.getenv("EUNOMIA_DATA_FOLDER")
name <- Sys.getenv("TEST_DB_NAME")
version <- Sys.getenv("TEST_DB_OMOP_VERSION")

# Connect to the duckdb test database
con <- DBI::dbConnect(
  duckdb::duckdb(dbdir = glue::glue("{dir}/{name}_{version}_1.0.duckdb"))
)
withr::defer(DBI::dbDisconnect(con))

# Function to write results from a table to the test data folder
write_results <- function(con, table) {
  schema <- Sys.getenv("TEST_DB_RESULTS_SCHEMA")
  # Get all rows from the table
  query <- glue::glue("SELECT * FROM {schema}.{table}")
  # Run the query and write results
  path <- here::here(glue::glue("inst/test_data/{table}.csv"))
  cli::cli_alert_info("Writing {table} to {path}")
  con |>
    DBI::dbGetQuery(query) |>
    arrange(across(everything())) |>
    readr::write_csv(file = path)
}

# Write all results to the test data folder
table_names <- c("calypso_concepts", "calypso_monthly_counts", "calypso_summary_stats")
purrr::walk(table_names, write_results, con = con)

cli::cli_alert_success("Test data produced")
