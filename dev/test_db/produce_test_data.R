
library(tidyverse)

dir <- Sys.getenv("EUNOMIA_DATA_FOLDER")
name <- Sys.getenv("TEST_DB_NAME")
version <- Sys.getenv("TEST_DB_OMOP_VERSION")

# Connect to the duckdb test database
con <- DBI::dbConnect(
  duckdb::duckdb(dbdir = glue::glue("{dir}/{name}_{version}_1.0.duckdb"))
)

# Function to write results from a table to the test data folder
write_results <- function(con, table) {
  schema <- Sys.getenv("TEST_DB_RESULTS_SCHEMA")
  # Get all rows from the table
  query <- glue::glue("SELECT * FROM {schema}.{table};")
  # Run the query and write results
  con |>
    DBI::dbGetQuery(query) |>
    write_csv(here::here(glue::glue("inst/test_data/{table}.csv")))
}

# Write all results to the test data folder
con |> write_results("calypso_concepts")
con |> write_results("calypso_monthly_counts")
con |> write_results("calypso_summary_stats")

# Clean up
DBI::dbDisconnect(con)
rm(write_results)
rm(con)
rm(dir)
rm(name)
rm(version)

detach("package:tidyverse", unload = TRUE)

