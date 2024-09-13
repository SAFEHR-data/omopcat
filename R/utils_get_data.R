#' Get input data for the app
#'
#' Utility functions to retrieve the input data for the app from the database.
#'
#' @noRd
get_concepts_table <- function() {
  if (golem::app_dev()) {
    ct <- readr::read_csv(
      app_sys("dev_data", "calypso_concepts.csv"),
      show_col_types = FALSE
    )
  } else {
    ct <- .read_parquet_table("calypso_concepts")
  }
  # Make sure the concept IDs are integers so that they get rendered as such
  # in shiny::renderTable()
  ct$concept_id <- as.integer(ct$concept_id)
  ct
}

get_monthly_counts <- function() {
  # If the app is run in development mode
  if (golem::app_dev()) {
    data <- readr::read_csv(app_sys("dev_data", "calypso_monthly_counts.csv"), show_col_types = FALSE)
  } else {
    data <- .read_parquet_table("calypso_monthly_counts")
  }
  .manage_low_frequency(data)
}

get_summary_stats <- function() {
  if (golem::app_dev()) {
    return(
      readr::read_csv(app_sys("dev_data", "calypso_summary_stats.csv"), show_col_types = FALSE)
    )
  }
  .read_parquet_table("calypso_summary_stats")
}

.read_parquet_table <- function(table_name) {
  data_dir <- Sys.getenv("CALYPSO_DATA_PATH")
  if (data_dir == "") {
    cli::cli_abort("Environment variable {.envvar CALYPSO_DATA_PATH} not set")
  }
  if (!dir.exists(data_dir)) {
    cli::cli_abort("Data directory {.file {data_dir}} not found")
  }

  nanoparquet::read_parquet(glue::glue("{data_dir}/{table_name}.parquet"))
}

# Manage low frequency statistics
# by removing values equal to 0 and
# by replacing values below the threshold with the replacement value
# (both defined in environment variables)
#' @importFrom rlang .data
.manage_low_frequency <- function(df) {
  threshold <- as.double(Sys.getenv("LOW_FREQUENCY_THRESHOLD"))
  replacement <- as.double(Sys.getenv("LOW_FREQUENCY_REPLACEMENT"))

  stopifnot("LOW_FREQUENCY_THRESHOLD is not a valid number" = !is.na(threshold))
  stopifnot("LOW_FREQUENCY_REPLACEMENT is not a valid number" = !is.na(replacement))
  # Remove records with values equal to 0
  df <- dplyr::filter(df, .data$records_per_person > 0)
  df <- dplyr::filter(df, .data$person_count > 0)
  # Replace values below the threshold with the replacement value
  dplyr::mutate(
    df,
    records_per_person = ifelse(.data$records_per_person < threshold, replacement, .data$records_per_person),
    person_count = ifelse(.data$person_count < threshold, replacement, .data$person_count)
  )
}
