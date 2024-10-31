#' Run the pre-processing pipeline
#'
#' @param out_path The directory where the pre-processed data will be written to
#'
#' @noRd
#' @export
preprocess <- function(out_path = Sys.getenv("OMOPCAT_DATA_PATH")) {
  cli::cli_alert_info("Preprocessing data to {.file {out_path}}")
}
