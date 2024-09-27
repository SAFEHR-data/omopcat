#' Should we be using the inst/dev_data?
#'
#' Only if we are running as a development server and OMOPCAT_DATA_PATH
#' is not set.
#'
#' @noRd
should_use_dev_data <- function() {
  golem::app_dev() && Sys.getenv("OMOPCAT_DATA_PATH") == ""
}


#' Get input data for the app
#'
#' Utility functions to retrieve the input data for the app from the database.
#'
#' @noRd
get_concepts_table <- function() {
  table_name <- "omopcat_concepts"
  if (should_use_dev_data()) {
    ct <- readr::read_csv(
      app_sys("dev_data", glue::glue("{table_name}.csv")),
      show_col_types = FALSE
    )
  } else {
    ct <- .read_parquet_table(table_name)
  }
  # Make sure the concept IDs are integers so that they get rendered as such
  # in shiny::renderTable()
  ct$concept_id <- as.integer(ct$concept_id)
  ct
}

get_monthly_counts <- function() {
  if (should_use_dev_data()) {
    data <- readr::read_csv(
      app_sys("dev_data", "omopcat_monthly_counts.csv"),
      col_types = readr::cols(
        concept_id = readr::col_integer(),
        date_year = readr::col_integer(),
        date_month = readr::col_integer()
      )
    )
  } else {
    data <- .read_parquet_table("omopcat_monthly_counts")
  }
  .manage_low_frequency(data)
}

get_summary_stats <- function() {
  if (should_use_dev_data()) {
    return(
      readr::read_csv(
        app_sys("dev_data", "omopcat_summary_stats.csv"),
        col_types = readr::cols(concept_id = readr::col_integer())
      )
    )
  }
  .read_parquet_table("omopcat_summary_stats")
}

filter_dates <- function(x, date_range) {
  date_range <- as.Date(date_range)
  if (date_range[2] < date_range[1]) {
    stop("Invalid date range, end date is before start date")
  }

  dates <- lubridate::make_date(year = x$date_year, month = x$date_month)
  keep_dates <- dplyr::between(dates, date_range[1], date_range[2])
  dplyr::filter(x, keep_dates)
}

.read_parquet_table <- function(table_name) {
  data_dir <- Sys.getenv("OMOPCAT_DATA_PATH")
  if (data_dir == "") {
    cli::cli_abort("Environment variable {.envvar OMOPCAT_DATA_PATH} not set")
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
