#' Generate the 'omopcat_monthly_counts' table
#'
#' @param cdm A [`CDMConnector`] object, e.g. from [`CDMConnector::cdm_from_con()`]
#' @param threshold Threshold value below which values will be replaced by `replacement`
#' @param replacement Value with which values below `threshold` will be replaced
#'
#' @return A `data.frame` with the monthly counts
#' @keywords internal
generate_monthly_counts <- function(cdm, threshold, replacement) {
  # Combine results for all tables
  out <- dplyr::bind_rows(
    cdm$condition_occurrence |> calculate_monthly_counts(
      .data$condition_concept_id, .data$condition_start_date
    ),
    cdm$drug_exposure |>
      calculate_monthly_counts(.data$drug_concept_id, .data$drug_exposure_start_date),
    cdm$procedure_occurrence |>
      calculate_monthly_counts(.data$procedure_concept_id, .data$procedure_date),
    cdm$device_exposure |>
      calculate_monthly_counts(.data$device_concept_id, .data$device_exposure_start_date),
    cdm$measurement |>
      calculate_monthly_counts(.data$measurement_concept_id, .data$measurement_date),
    cdm$observation |>
      calculate_monthly_counts(.data$observation_concept_id, .data$observation_date),
    cdm$specimen |>
      calculate_monthly_counts(.data$specimen_concept_id, .data$specimen_date)
  )

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


#' Calculate monthly statistics for an OMOP concept
#'
#' @param omop_table A table from the OMOP CDM
#' @param concept The name of the concept column to calculate statistics for
#' @param date The name of the date column to calculate statistics for
#'
#' @return A `data.frame` with the following columns:
#'   - `concept_id`: The concept ID
#'   - `concept_name`: The concept name
#'   - `date_year`: The year of the date
#'   - `date_month`: The month of the date
#'   - `person_count`: The number of unique patients per concept for each month
#'   - `records_per_person`: The average number of records per person per concept for each month
#' @keywords internal
calculate_monthly_counts <- function(omop_table, concept, date) {
  # Extract year and month from date column
  omop_table <- dplyr::mutate(omop_table,
    concept_id = {{ concept }},
    date_year = as.integer(lubridate::year({{ date }})),
    date_month = as.integer(lubridate::month({{ date }}))
  )

  omop_table |>
    dplyr::group_by(.data$date_year, .data$date_month, .data$concept_id) |>
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
      "date_month",
      "record_count",
      "person_count",
      "records_per_person"
    ) |>
    ## Collect in case we're dealing with a database-stored table
    dplyr::collect()
}
