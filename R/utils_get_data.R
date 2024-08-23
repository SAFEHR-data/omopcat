#' Get input data for the app
#'
#' Utility functions to retrieve the input data for the app from the database.
#'
#' @noRd
get_concepts_table <- function() {
  if (golem::app_dev()) {
    return(
      read.csv(app_sys("test_data", "calypso_concepts.csv"))
    )
  }

  con <- connect_to_test_db()
  withr::defer(DBI::dbDisconnect(con))
  DBI::dbReadTable(con, "calypso_concepts")
}

get_monthly_counts <- function() {
  if (golem::app_dev()) {
    return(
      read.csv(app_sys("test_data", "calypso_monthly_counts.csv"))
    )
  }

  con <- connect_to_test_db()
  withr::defer(DBI::dbDisconnect(con))
  DBI::dbReadTable(con, "calypso_monthly_counts")
}

get_summary_stats <- function() {
  if (golem::app_dev()) {
    return(
      read.csv(app_sys("test_data", "calypso_summary_stats.csv"))
    )
  }

  con <- connect_to_test_db()
  withr::defer(DBI::dbDisconnect(con))
  DBI::dbReadTable(con, "calypso_summary_stats")
}
