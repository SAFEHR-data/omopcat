# nocov start

#' Connec to a database
#'
#' General helper to connect to a databae through [`DBI::dbConnect()`], while ensuring
#' that the connection is closed when the connection object goes out of scope.
#'
#' @param ... arguments passed on to [`DBI::dbConnect()`]
#'
#' @return A [`DBI::DBIConnection-class`] object
#' @export
connect_to_db <- function(..., .envir = parent.frame()) {
  con <- DBI::dbConnect(...)
  withr::defer(DBI::dbDisconnect(con), envir = .envir)
  con
}

#' Connect to duckdb database
#'
#' @param db_path path to the duckdb database file
#' @param ... unused
#' @param .envir passed on to [`withr::defer()`]
#'
#' @return A [`DBI::DBIConnection-class`] object
#' @export
connect_to_test_duckdb <- function(db_path, ..., .envir = parent.frame()) {
  if (!file.exists(db_path)) {
    cli::cli_abort("Database file {.file {db_path}} not found")
  }

  # Connect to the duckdb test database
  rlang::check_installed("duckdb", reason = "to set up test database connection")
  connect_to_db(duckdb::duckdb(dbdir = db_path))
}


#' Write data to a table in the database
#'
#' @param data data.frame, data to be written to the table
#' @param con A [`DBI::DBIConnection-class`] object
#' @param table character, name of the table to write to
#' @param schema character, name of the schema to be used
#'
#' @return `TRUE`, invisibly, if the operation was successful
#' @export
write_table <- function(data, con, table, schema) {
  DBI::dbWriteTable(
    conn = con,
    name = DBI::Id(schema = schema, table = table),
    value = data,
    overwrite = TRUE
  )
}


#' Read a parquet table and sort the results
#'
#' @param path path to the parquet file to be read
#' @inheritParams nanoparquet::read_parquet
#'
#' @return A `data.frame` with the results sorted by all columns
#' @export
#' @importFrom dplyr arrange across everything
read_parquet_sorted <- function(path, options = nanoparquet::parquet_options()) {
  if (!file.exists(path)) {
    cli::cli_abort("File {.file {path}} not found")
  }

  nanoparquet::read_parquet(path, options) |>
    arrange(across(everything()))
}

# Function to produce the 'omopcat_concepts' table
# from a list of concept ids
#' @export
query_concepts_table <- function(cdm, concepts) {
  # Extract columns from concept table
  cdm$concept |>
    filter(.data$concept_id %in% concepts) |>
    select(
      "concept_id",
      "concept_name",
      "vocabulary_id",
      "domain_id",
      "concept_class_id",
      "standard_concept",
      "concept_code"
    ) |>
    collect()
}

# Function to produce the 'omopcat_monthly_counts' table
#' @export
process_monthly_counts <- function(cdm) {
  # Combine results for all tables
  out <- bind_rows( # nolint start
    cdm$condition_occurrence |> calculate_monthly_counts(condition_concept_id, condition_start_date),
    cdm$drug_exposure |> calculate_monthly_counts(drug_concept_id, drug_exposure_start_date),
    cdm$procedure_occurrence |> calculate_monthly_counts(procedure_concept_id, procedure_date),
    cdm$device_exposure |> calculate_monthly_counts(device_concept_id, device_exposure_start_date),
    cdm$measurement |> calculate_monthly_counts(measurement_concept_id, measurement_date),
    cdm$observation |> calculate_monthly_counts(observation_concept_id, observation_date),
    cdm$specimen |> calculate_monthly_counts(specimen_concept_id, specimen_date)
  ) # nolint end

  # Map concept names to the concept IDs
  concept_names <- select(cdm$concept, .data$concept_id, .data$concept_name) |>
    filter(.data$concept_id %in% out$concept_id) |>
    collect()
  out |>
    dplyr::left_join(concept_names, by = c("concept_id" = "concept_id")) |>
    select("concept_id", "concept_name", everything())
}

# Function to produce the 'omopcat_summary_stats' table
#' @export
process_summary_stats <- function(cdm) {
  table_names <- c("measurement", "observation")
  concept_names <- c("measurement_concept_id", "observation_concept_id")

  # Combine results for all tables
  stats <- purrr::map2(table_names, concept_names, ~ calculate_summary_stats(cdm[[.x]], .y))
  stats <- bind_rows(stats)

  # Map concept names to the concept_ids
  concept_names <- select(cdm$concept, "concept_id", "concept_name") |>
    filter(.data$concept_id %in% c(stats$concept_id, stats$value_as_concept_id)) |>
    collect()
  stats |>
    # Order is important here, first we get the names for the value_as_concept_ids
    # from the categorical data summaries and record it as `value_as_string`
    dplyr::left_join(concept_names, by = c("value_as_concept_id" = "concept_id")) |>
    rename(value_as_string = "concept_name") |>
    # Then we get the names for the main concept_ids
    dplyr::left_join(concept_names, by = c("concept_id" = "concept_id")) |>
    select("concept_id", "concept_name", !"value_as_concept_id")
}

# nocov end
