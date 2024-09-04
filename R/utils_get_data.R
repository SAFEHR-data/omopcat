#' Get input data for the app
#'
#' Utility functions to retrieve the input data for the app from the database.
#'
#' @noRd
get_concepts_table <- function() {
  if (golem::app_dev()) {
    return(
      readr::read_csv(app_sys("dev_data", "calypso_concepts.csv"), show_col_types = FALSE)
    )
  }
  .read_parquet_table("calypso_concepts")
}

get_monthly_counts <- function() {
  if (golem::app_dev()) {
    return(
      readr::read_csv(app_sys("dev_data", "calypso_monthly_counts.csv"), show_col_types = FALSE)
    )
  }
  .read_parquet_table("calypso_monthly_counts")
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
