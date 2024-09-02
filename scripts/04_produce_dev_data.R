cli::cli_h1("Producing test data")


# Setup ---------------------------------------------------------------------------------------

suppressPackageStartupMessages({
  library(dplyr)
  library(calypso)
})

dir <- Sys.getenv("EUNOMIA_DATA_FOLDER")
name <- Sys.getenv("TEST_DB_NAME")
version <- Sys.getenv("TEST_DB_OMOP_VERSION")

db_path <- glue::glue("{dir}/{name}_{version}_1.0.duckdb")
out_path <- here::here("inst/dev_data")
stopifnot(dir.exists(out_path))

con <- connect_to_db(db_path)


# Produce test data ---------------------------------------------------------------------------

# Get the relevant tables and filter
table_names <- c("calypso_concepts", "calypso_monthly_counts", "calypso_summary_stats")
tables <- purrr::map(
  table_names, read_table_sorted,
  con = con, schema = Sys.getenv("TEST_DB_RESULTS_SCHEMA")
)
names(tables) <- table_names

# Keep only concepts for which we have summary statistics
keep_concepts <- tables$calypso_summary_stats$concept_id
tables <- purrr::map(tables, ~ .x[.x$concept_id %in% keep_concepts, ])

# Keep only data from 2019 onwards
monthly_counts <- tables$calypso_monthly_counts
filtered_monthly <- monthly_counts[monthly_counts$date_year >= 2019, ]
tables$calypso_monthly_counts <- filtered_monthly

# Filter the other tables to match the concepts left over after year filtering
tables <- purrr::map(tables, ~ .x[.x$concept_id %in% filtered_monthly$concept_id, ])

# Write all results to the test data folder
purrr::iwalk(tables, function(tbl, name) {
  path <- glue::glue("{out_path}/{name}.csv")
  cli::cli_alert_info("Writing {name} to {path}")
  readr::write_csv(tbl, file = path)
})

cli::cli_alert_success("Test data produced")
