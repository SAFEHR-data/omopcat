cli::cli_h1("Producing test data")


# Setup ---------------------------------------------------------------------------------------

suppressPackageStartupMessages({
  library(dplyr)
  library(calypso)
})

data_path <- here::here("data/test_data")
stopifnot(dir.exists(data_path))
out_path <- here::here("inst/dev_data")
stopifnot(dir.exists(out_path))

# Produce test data ---------------------------------------------------------------------------

# Get the relevant tables and filter
table_names <- c("concepts", "monthly_counts", "summary_stats")
paths <- glue::glue("{data_path}/calypso_{table_names}.parquet")
tables <- purrr::map(paths, read_parquet_sorted)
names(tables) <- table_names

# Keep only concepts for which we have summary statistics
keep_concepts <- tables$summary_stats$concept_id
tables <- purrr::map(tables, ~ .x[.x$concept_id %in% keep_concepts, ])

# Keep only data from 2019 onwards
monthly_counts <- tables$monthly_counts
filtered_monthly <- monthly_counts[monthly_counts$date_year >= 2019, ]
tables$monthly_counts <- filtered_monthly

# Filter the other tables to match the concepts left over after year filtering
tables <- purrr::map(tables, ~ .x[.x$concept_id %in% filtered_monthly$concept_id, ])

# Write all results to the test data folder
purrr::iwalk(tables, function(tbl, name) {
  path <- glue::glue("{out_path}/calypso_{name}.csv")
  cli::cli_alert_info("Writing {name} to {path}")
  readr::write_csv(tbl, file = path)
})

cli::cli_alert_success("Test data produced")
