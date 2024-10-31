#' Run the pre-processing pipeline
#'
#' The pre-processing pipeline generates the following files:
#'
#' * `out_path`/omopcat_concepts.parquet
#' * `out_path`/omopcat_monthly_counts.parquet
#' * `out_path`/omopcat_summary_stats.parquet
#'
#' If all these files already exist, the pipeline will not be run.
#'
#' @param out_path The directory where the pre-processed data will be written to.
#'   Defaults  to the `OMOPCAT_DATA_PATH` environment variable.
#'
#' @return Whether the pre-processing was run: `TRUE` or `FALSE`, invisibly.
#'
#' @noRd
#' @export
preprocess <- function(out_path = Sys.getenv("PREPROCESS_OUT_PATH")) {
  if (out_path == "") {
    cli::cli_abort(c(
      "x" = "{.var out_path} should not be empty.",
      "i" = "Have you set the {.envvar PREPROCESS_OUT_PATH} environment variable?"
    ))
  }
  fs::dir_create(out_path)

  out_files <- c(
    file.path(out_path, "omopcat_concepts.parquet"),
    file.path(out_path, "omopcat_monthly_counts.parquet"),
    file.path(out_path, "omopcat_summary_stats.parquet")
  )

  # Only run pre-processing if the expected files don't exist
  exists <- fs::file_exists(out_files)

  if (all(exists)) {
    cli::cli_alert_info("All expected files already exist. Skipping pre-processing.")
    cli::cli_alert_info("To force re-processing, delete the following files:")
    cli::cli_ul(out_files[exists])

    return(invisible(FALSE))
  }

  if (.running_in_production()) {
    cli::cli_alert_info("Running in production mode")
    .check_prod_env()
  }

  cli::cli_alert_info("Running pre-processing with {.var out_path} = {.file {out_path}}")
  # TODO: run pre-processing
  return(invisible(TRUE))
}

.running_in_production <- function() {
  return(Sys.getenv("ENV") == "prod")
}

.check_prod_env <- function() {
  required_envvars <- c(
    "DB_NAME",
    "HOST",
    "PORT",
    "DB_USERNAME",
    "DB_PASSWORD",
    "PREPROCESS_OUT_PATH"
  )

  missing <- Sys.getenv(required_envvars) == ""
  if (any(missing)) {
    cli::cli_abort(c(
      "x" = "Environment variable{?s} {.envvar {required_envvars[missing]}} not set",
      "i" = "Make sure to define the environment variables in a local {.file .Renviron} file"
    ), call = rlang::caller_env())
  }
}
