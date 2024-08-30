#' Connect to duckdb database
#'
#' @param db_path path to the duckdb database file
#' @param ... unused
#' @param .envir passed on to [`withr::defer()`]
#'
#' @return A [`DBI::DBIConnection-class`] object
#' @export
connect_to_db <- function(db_path, ..., .envir = parent.frame()) {
  if (!file.exists(db_path)) {
    cli::cli_abort("Database file {.file {db_path}} not found")
  }

  # Connect to the duckdb test database
  con <- DBI::dbConnect(
    duckdb::duckdb(dbdir = db_path)
  )
  withr::defer(DBI::dbDisconnect(con), envir = .envir)
  con
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


#' Read a table from the database and sort the results
#'
#' @inheritParams write_table
#'
#' @return A `data.frame` with the results sorted by all columns
#' @export
#' @importFrom dplyr arrange across everything
read_table_sorted <- function(con, table, schema) {
  # Get all rows from the table
  query <- glue::glue("SELECT * FROM {schema}.{table}")
  # Run the query and sort results
  DBI::dbGetQuery(con, query) |>
    arrange(across(everything()))
}
