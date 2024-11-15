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
#'   Defaults  to the `PREPROCESS_OUT_PATH` environment variable.
#'
#' @return Whether the pre-processing was run: `TRUE` or `FALSE`, invisibly.
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
    concepts = file.path(out_path, "omopcat_concepts.parquet"),
    monthly_counts = file.path(out_path, "omopcat_monthly_counts.parquet"),
    summary_stats = file.path(out_path, "omopcat_summary_stats.parquet")
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

  cdm <- .setup_cdm_object()

  threshold <- Sys.getenv("LOW_FREQUENCY_THRESHOLD")
  replacement <- Sys.getenv("LOW_FREQUENCY_REPLACEMENT")

  cli::cli_progress_message("Generating monthly_counts table")
  monthly_counts <- generate_monthly_counts(cdm, threshold = threshold, replacement = replacement)

  cli::cli_progress_message("Generating summary_stats table")
  summary_stats <- generate_summary_stats(cdm, threshold = threshold, replacement = replacement)

  cli::cli_progress_message("Generating concepts table")
  concept_ids_with_data <- unique(c(monthly_counts$concept_id, summary_stats$concept_id))
  concepts_table <- generate_concepts(cdm, concept_ids = concept_ids_with_data)

  nanoparquet::write_parquet(concepts_table, out_files["concepts"])
  nanoparquet::write_parquet(monthly_counts, out_files["monthly_counts"])
  nanoparquet::write_parquet(summary_stats, out_files["summary_stats"])
  cli::cli_alert_success("Tables written to {.path {out_files}}")

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
    "LOW_FREQUENCY_THRESHOLD",
    "LOW_FREQUENCY_REPLACEMENT"
  )

  missing <- Sys.getenv(required_envvars) == ""
  if (any(missing)) {
    cli::cli_abort(
      "Environment variable{?s} {.envvar {required_envvars[missing]}} not set",
      call = rlang::caller_env()
    )
  }
}

#' Set up a CDM object from a database connection
#'
#' When running in production, sets up a CDM object from the database settings
#' configured through the relevant environment variables.
#'
#' When not in production, creates a CDM from one of the CDMConnector example
#' datasets (`"GiBleed"` by default), using [`CDMConnector::eunomia_dir()`].
#' This is intended for use in testing and development.
#'
#' @param .envir Passed on to [`connect_to_db()`], controls the scope in which the database
#'    connection should live. When it goes out of scope, the database connection is closed.
#' @noRd
.setup_cdm_object <- function(.envir = parent.frame()) {
  if (.running_in_production()) {
    name <- Sys.getenv("DB_NAME")
    con <- connect_to_db(
      RPostgres::Postgres(),
      dbname = Sys.getenv("DB_NAME"),
      host = Sys.getenv("HOST"),
      port = Sys.getenv("PORT"),
      user = Sys.getenv("DB_USERNAME"),
      password = Sys.getenv("DB_PASSWORD"),
      .envir = parent.frame()
    )
  } else {
    name <- Sys.getenv("DB_NAME", unset = "GiBleed")
    duckdb_path <- CDMConnector::eunomia_dir(dataset_name = name)
    rlang::check_installed("duckdb")
    con <- connect_to_db(duckdb::duckdb(duckdb_path), .envir = .envir)
  }

  # Load the data in a CDMConnector object
  CDMConnector::cdm_from_con(
    con = con,
    cdm_schema = Sys.getenv("DB_CDM_SCHEMA", unset = "main"),
    write_schema = Sys.getenv("DB_CDM_SCHEMA", unset = "main"),
    cdm_name = name
  )
}
