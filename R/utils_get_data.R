#' Get input data for the app
#'
#' Utility functions to retrieve the input data for the app from the database.
#'
#' @noRd
get_concepts_table <- function() {
  if (golem::app_dev()) {
    return(
      readr::read_csv(app_sys("test_data", "calypso_concepts.csv"), show_col_types = FALSE)
    )
  }
  .read_db_table("calypso_concepts")
}

get_monthly_counts <- function() {
  if (golem::app_dev()) {
    return(
      readr::read_csv(app_sys("test_data", "calypso_monthly_counts.csv"), show_col_types = FALSE)
    )
  }
  .read_db_table("calypso_monthly_counts")
}

get_summary_stats <- function() {
  if (golem::app_dev()) {
    return(
      readr::read_csv(app_sys("test_data", "calypso_summary_stats.csv"), show_col_types = FALSE)
    )
  }
  .read_db_table("calypso_summary_stats")
}

.connect_to_db <- function() {
  dir <- Sys.getenv("CALYPSO_DATA_PATH")
  name <- Sys.getenv("CALYPSO_DB_NAME")
  version <- Sys.getenv("CALYPSO_DB_OMOP_VERSION")

  db_file <- glue::glue("{dir}/{name}_{version}_1.0.duckdb")
  if (!file.exists(db_file)) {
    cli::cli_abort("Database file {.file {db_file}} does not exist.")
  }

  # Connect to the duckdb database
  DBI::dbConnect(duckdb::duckdb(dbdir = db_file))
}

.read_db_table <- function(table_name) {
  con <- .connect_to_db()
  withr::defer(DBI::dbDisconnect(con))
  DBI::dbReadTable(con, table_name)
}
