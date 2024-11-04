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

  cli::cli_progress_message("Generating monthly_counts table")
  monthly_counts <- generate_monthly_counts(cdm)

  cli::cli_progress_message("Generating summary_stats table")
  summary_stats <- generate_summary_stats(cdm)

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
    "DB_PASSWORD"
  )

  missing <- Sys.getenv(required_envvars) == ""
  if (any(missing)) {
    cli::cli_abort(
      "Environment variable{?s} {.envvar {required_envvars[missing]}} not set",
      call = rlang::caller_env()
    )
  }
}

.setup_cdm_object <- function() {
  if (.running_in_production()) {
    name <- Sys.getenv("DB_NAME")
    con <- connect_to_db(
      RPostgres::Postgres(),
      dbname = Sys.getenv("DB_NAME"),
      host = Sys.getenv("HOST"),
      port = Sys.getenv("PORT"),
      user = Sys.getenv("DB_USERNAME"),
      password = Sys.getenv("DB_PASSWORD")
    )
  } else {
    dir <- Sys.getenv("EUNOMIA_DATA_FOLDER")
    name <- Sys.getenv("TEST_DB_NAME")
    version <- Sys.getenv("TEST_DB_OMOP_VERSION")

    db_path <- glue::glue("{dir}/{name}_{version}_1.0.duckdb")
    con <- connect_to_test_duckdb(db_path)
  }

  # Load the data in a CDMConnector object
  CDMConnector::cdm_from_con(
    con = con,
    cdm_schema = Sys.getenv("DB_CDM_SCHEMA"),
    write_schema = Sys.getenv("DB_CDM_SCHEMA"),
    cdm_name = name
  )
}
