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
