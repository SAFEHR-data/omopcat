cli::cli_h1("Producing test data")

suppressPackageStartupMessages(
  library(tidyverse)
)

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
con |> write_results("calypso_concepts", "ORDER BY concept_id")
con |> write_results("calypso_monthly_counts", "ORDER BY concept_id, date_year, date_month")
con |> write_results("calypso_summary_stats", "ORDER BY concept_id, summary_attribute")

cli::cli_alert_success("Test data produced")
