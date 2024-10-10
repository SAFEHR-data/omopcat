# Master script to create the prod data
# Generates the `data/prod_data/*.parquet` files

here::i_am("scripts/create_prod_data.R")

Sys.setenv("ENV" = "prod")

required_envvars <- c(
  "DB_NAME",
  "HOST",
  "PORT",
  "DB_USERNAME",
  "DB_PASSWORD"
)

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

source(here::here("scripts/03_analyse_omop_cdm.R"))

expected_files <- c(
  here::here("data/prod_data/omopcat_concepts.parquet"),
  here::here("data/prod_data/omopcat_monthly_counts.parquet"),
  here::here("data/prod_data/omopcat_summary_stats.parquet")
)

check_exists <- function(path) {
  if (!file.exists(path)) {
    cli::cli_abort("Expected file not found: {.file {path}}")
  }
}
purrr::walk(expected_files, check_exists)
