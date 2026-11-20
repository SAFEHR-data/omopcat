#' Generate the `omopcat_records_dates` table
#'
#' Read source release date from the metadata.
#' Date 'NA' for the synthetic data
#'
#' @param cdm A [`CDMConnector`] object
#'
#' @return A `data.frame` with `source_release_date`
#' @keywords internal
#'
generate_records_dates <- function(cdm) {
  release_date <- as.Date(NA)

  if ("cdm_source" %in% names(cdm)) {
    dates <- dplyr::collect(cdm$cdm_source)$source_release_date
    dates <- as.Date(dates)
    dates <- dates[!is.na(dates)]
    # if more than one rows use max
    if (length(dates) > 0) {
      release_date <- max(dates)
    }
  }
  data.frame(source_release_date = release_date)
}
