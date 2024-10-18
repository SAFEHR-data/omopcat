# Master script to create the prod data
# Generates the `data/prod_data/*.parquet` files

here::i_am("scripts/create_prod_data.R")

Sys.setenv("ENV" = "prod")

required_envvars <- c(
  "DB_NAME",
  "HOST",
  "PORT",
  "DB_USERNAME",
  "DB_PASSWORD",
  "OMOPCAT_DATA_PATH"
)

out_path <- Sys.getenv("OMOPCAT_DATA_PATH")

check_envvars <- function(x) {
  missing <- Sys.getenv(x) == ""
  if (any(missing)) {
    cli::cli_abort(c(
      "x" = "Environment variable{?s} {.envvar {x[missing]}} not set",
      "i" = "Make sure to define the environment variables in a local {.file .Renviron} file"
    ), call = rlang::caller_env())
  }
}
check_envvars(required_envvars)

expected_files <- c(
  file.path(out_path, "omopcat_concepts.parquet"),
  file.path(out_path, "omopcat_monthly_counts.parquet"),
  file.path(out_path, "omopcat_summary_stats.parquet")
)

# Only run pre-processing if the expected files don't exist
exists <- file.exists(expected_files)
if (!all(exists)) {
  source(here::here("scripts/03_analyse_omop_cdm.R"))
  # Sanity check: make sure the expected files were created
  purrr::walk(expected_files, function(path) {
    if (!file.exists(path)) {
      cli::cli_abort("Expected file not found: {.file {path}}")
    }
  })
} else {
  cli::cli_alert_info("All expected files already exist. Skipping pre-processing.")
  cli::cli_alert_info("To force re-processing, delete the following files:")
  cli::cli_ul(expected_files[exists])
}
