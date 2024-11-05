# nocov start

#' Connect to a database
#'
#' General helper to connect to a database through [`DBI::dbConnect()`], while ensuring
#' that the connection is closed when the connection object goes out of scope.
#'
#' @param ... arguments passed on to [`DBI::dbConnect()`]
#' @param .envir passed on to [`withr::defer()`]
#'
#' @return A [`DBI::DBIConnection-class`] object
connect_to_db <- function(..., .envir = parent.frame()) {
  con <- DBI::dbConnect(...)
  withr::defer(DBI::dbDisconnect(con), envir = .envir)
  con
}

# TODO: remove what is not used anymore

#' Write data to a table in the database
#'
#' @param data data.frame, data to be written to the table
#' @param con A [`DBI::DBIConnection-class`] object
#' @param table character, name of the table to write to
#' @param schema character, name of the schema to be used
#'
#' @return `TRUE`, invisibly, if the operation was successful
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
#' @importFrom dplyr arrange across everything
read_parquet_sorted <- function(path, options = nanoparquet::parquet_options()) {
  if (!file.exists(path)) {
    cli::cli_abort("File {.file {path}} not found")
  }

  nanoparquet::read_parquet(path, options) |>
    arrange(across(everything()))
}

#' Function to produce the 'omopcat_concepts' table from a list of concept ids
#'
#' @param cdm A [`CDMConnector`] object, e.g. from [`CDMConnector::cdm_from_con()`]
#' @param concepts A vector of concept IDs
#'
#' @return A `data.frame` with the concept table
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

#' Generate the 'omopcat_summary_stats' table

#' @param cdm A [`CDMConnector`] object, e.g. from [`CDMConnector::cdm_from_con()`]
#'
#' @return A `data.frame` with the summary statistics
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
