#' connect_to_test_db
#'
#' Connect to the test database
#' (using environment variables from .Rprofile)
#'
#' @return A DBI connection to the test database
#'
#' @importFrom DBI dbConnect
#' @importFrom duckdb duckdb
#' @importFrom glue glue
#'
#' @noRd
connect_to_test_db <- function() {
  dir <- Sys.getenv("CALYPSO_DATA_PATH")
  name <- Sys.getenv("CALYPSO_DB_NAME")
  version <- Sys.getenv("CALYPSO_DB_OMOP_VERSION")
  # Connect to the duckdb test database
  dbConnect(duckdb(dbdir = glue("{dir}/{name}_{version}_1.0.duckdb")))
}
