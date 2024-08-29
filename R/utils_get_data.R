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

  con <- connect_to_test_db()
  withr::defer(DBI::dbDisconnect(con))
  DBI::dbReadTable(con, "calypso_concepts")
}

get_monthly_counts <- function() {
  # Manage low frequency statistics
  # by replacing values below the threshold with the replacement value
  # (both defined in environment variables)
  manage_low_frequency <- function(df) {
    threshold <- as.double(Sys.getenv("LOW_FREQUENCY_THRESHOLD"))
    replacement <- as.double(Sys.getenv("LOW_FREQUENCY_REPLACEMENT"))
    df <- dplyr::mutate(
      df,
      person_count = ifelse(person_count < threshold, replacement, person_count)
    )
    df <- dplyr::mutate(
      df,
      records_per_person = ifelse(records_per_person < threshold, replacement, records_per_person)
    )
    df
  }

  if (golem::app_dev()) {
    return(
      {
        data <- readr::read_csv(app_sys("test_data", "calypso_monthly_counts.csv"), show_col_types = FALSE)
        manage_low_frequency(data)
      }
    )
  }

  con <- connect_to_test_db()
  withr::defer(DBI::dbDisconnect(con))
  data <- DBI::dbReadTable(con, "calypso_monthly_counts")
  manage_low_frequency(data)
}

get_summary_stats <- function() {
  if (golem::app_dev()) {
    return(
      readr::read_csv(app_sys("test_data", "calypso_summary_stats.csv"), show_col_types = FALSE)
    )
  }

  con <- connect_to_test_db()
  withr::defer(DBI::dbDisconnect(con))
  DBI::dbReadTable(con, "calypso_summary_stats")
}
