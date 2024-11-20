#' Generate the 'omopcat_monthly_counts' table
#'
#' @param cdm A [`CDMConnector`] object, e.g. from [`CDMConnector::cdm_from_con()`]
#' @param threshold Threshold value below which values will be replaced by `replacement`
#' @param replacement Value with which values below `threshold` will be replaced
#' @param level At which resolution the counts should be summarised.
#'    Currently supports `"monthly"` or `"quarterly"`.
#'
#' @return A `data.frame` with the monthly counts
#' @keywords internal
generate_monthly_counts <- function(cdm, threshold, replacement,
                                    level = c("monthly", "quarterly")) {
  level <- match.arg(level)
  .summarise <- function(...) summarise_counts(..., level = level)

  # Combine results for all tables
  arg_list <- list(
    list(
      omop_table = cdm[["measurement"]],
      concept_col = "measurement_concept_id",
      date_col = "measurement_date"
    ),
    list(
      omop_table = cdm[["observation"]],
      concept_col = "observation_concept_id",
      date_col = "observation_date"
    ),
    list(
      omop_table = cdm[["condition_occurrence"]],
      concept_col = "condition_concept_id",
      date_col = "condition_start_date"
    ),
    list(
      omop_table = cdm[["drug_exposure"]],
      concept_col = "drug_concept_id",
      date_col = "drug_exposure_start_date"
    ),
    list(
      omop_table = cdm[["procedure_occurrence"]],
      concept_col = "procedure_concept_id",
      date_col = "procedure_date"
    ),
    list(
      omop_table = cdm[["device_exposure"]],
      concept_col = "device_concept_id",
      date_col = "device_exposure_start_date"
    ),
    list(
      omop_table = cdm[["specimen"]],
      concept_col = "specimen_concept_id",
      date_col = "specimen_date"
    )
  )

  out <- purrr::map_dfr(arg_list, ~ do.call(.summarise, .))

  # Map concept names to the concept IDs
  concept_names <- dplyr::select(cdm$concept, "concept_id", "concept_name") |>
    dplyr::filter(.data$concept_id %in% out$concept_id) |>
    dplyr::collect()
  out |>
    dplyr::left_join(concept_names, by = c("concept_id" = "concept_id")) |>
    dplyr::select("concept_id", "concept_name", dplyr::everything()) |>
    replace_low_frequencies(
      cols = c("record_count", "person_count", "records_per_person"),
      threshold = threshold, replacement = replacement
    )
}

#' Summarise record counts
#'
#' @param omop_table A table from the OMOP CDM
#' @param concept_col The name of the concept column to calculate statistics for
#' @param date_col The name of the date column to calculate statistics for
#' @param level The resolution at which to summarise the record counts.
#'    Currently supports `"monthly"` or `"quarterly"`
#'
#' @return A `data.frame` with the following columns:
#'   - `concept_id`: The concept ID
#'   - `concept_name`: The concept name
#'   - `date_year`: The year of the date
#'   - `date_month` or `date_quarter`: The month or quarter of the date, depending on `level`
#'   - `person_count`: The number of unique patients per concept for each month
#'   - `records_per_person`: The average number of records per person per concept for each month
#' @keywords internal
summarise_counts <- function(omop_table, concept_col, date_col, level) {
  group_by_var <- switch(level,
    monthly = "date_month",
    quarterly = "date_quarter",
    stop(sprintf("Summary level `%s` not supported", level))
  )

  # Extract year, month and quarter from date column
  omop_table <- dplyr::mutate(omop_table,
    concept_id = .data[[concept_col]],
    date_year = as.integer(lubridate::year(.data[[date_col]])),
    date_month = as.integer(lubridate::month(.data[[date_col]]))
  )

  if (level == "quarterly") {
    # NOTE: lubridate::quarter is not supported for all SQL back-ends
    omop_table <- omop_table |>
      dplyr::mutate(date_quarter = as.integer(lubridate::quarter(.data[[date_col]])))
  }

  omop_table |>
    dplyr::group_by(.data$date_year, .data[[group_by_var]], .data$concept_id) |>
    dplyr::summarise(
      record_count = dplyr::n(),
      person_count = dplyr::n_distinct(.data$person_id),
    ) |>
    # NOTE: Explicitly cast types to avoid unexpected SQL behaviour,
    # otherwise the records_per_person might end up as an int
    # and the *_count vars as int64, which can give problems later
    dplyr::mutate(
      record_count = as.integer(.data$record_count),
      person_count = as.integer(.data$person_count),
      records_per_person = as.double(.data$record_count) / as.double(.data$person_count)
    ) |>
    dplyr::select(
      "concept_id",
      "date_year",
      dplyr::all_of(group_by_var),
      "record_count",
      "person_count",
      "records_per_person"
    ) |>
    ## Collect in case we're dealing with a database-stored table
    dplyr::collect()
}
