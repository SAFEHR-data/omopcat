#' connect_to_test_db
#'
#' @description Connect to the test database
#' @description (using environment variables from .Rprofile)
#'
#' @return A DBI connection to the test database
#'
#' @importFrom DBI dbConnect
#' @importFrom duckdb duckdb
#' @importFrom glue glue
#'
#' @noRd
connect_to_test_db <- function() {
  dir <- Sys.getenv("EUNOMIA_DATA_FOLDER")
  name <- Sys.getenv("TEST_DB_NAME")
  version <- Sys.getenv("TEST_DB_OMOP_VERSION")
  # Connect to the duckdb test database
  dbConnect(duckdb(dbdir = glue("{dir}/{name}_{version}_1.0.duckdb")))
}
