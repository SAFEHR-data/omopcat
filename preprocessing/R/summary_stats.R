#' Generate the `omopcat_summary_stats` table
#'
#' @param cdm A [`CDMConnector`] object, e.g. from [`CDMConnector::cdm_from_con()`]
#'
#' @return A `data.frame` with the summary statistics
#' @keywords internal
generate_summary_stats <- function(cdm) {
  omop_tables <- cdm[c("measurement", "observation")]
  concept_cols <- c("measurement_concept_id", "observation_concept_id")

  # Combine results for all tables
  stats <- purrr::map2(omop_tables, concept_cols, calculate_summary_stats)
  stats <- dplyr::bind_rows(stats)

  # Map concept names to the concept_ids
  concept_names <- dplyr::select(cdm$concept, "concept_id", "concept_name") |>
    dplyr::filter(.data$concept_id %in% c(stats$concept_id, stats$value_as_concept_id)) |>
    dplyr::collect()
  stats |>
    # Order is important here, first we get the names for the value_as_concept_ids
    # from the categorical data summaries and record it as `value_as_string`
    dplyr::left_join(concept_names, by = c("value_as_concept_id" = "concept_id")) |>
    dplyr::rename(value_as_string = "concept_name") |>
    # Then we get the names for the main concept_ids
    dplyr::left_join(concept_names, by = c("concept_id" = "concept_id")) |>
    dplyr::select("concept_id", "concept_name", !"value_as_concept_id")
}

#' Calculate summary statistics for an OMOP table
#'
#' Calculates the mean and standard deviation for numeric concepts and the
#' frequency for categorical concepts.
#'
#' @param omop_table A table from the OMOP CDM
#' @param concept_name The name of the concept ID column
#'
#' @return A `data.frame` with the following columns:
#'  - `concept_id`: The concept ID
#'  - `summary_attribute`: The summary attribute (e.g. `"mean"`, `"sd"`, `"frequency"`)
#'  - `value_as_number`: The value of the summary attribute
#'  - `value_as_concept_id`: In case of a categorical concept, the concept ID for each category
#' @keywords internal
calculate_summary_stats <- function(omop_table, concept_name) {
  stopifnot(is.character(concept_name))
  stopifnot(concept_name %in% colnames(omop_table))

  omop_table <- dplyr::rename(omop_table, concept_id = dplyr::all_of(concept_name))

  numeric_concepts <- filter(omop_table, !is.na(.data$value_as_number))
  # beware CDM docs: NULL=no categorical result, 0=categorical result but no mapping
  categorical_concepts <- filter(
    omop_table,
    !is.null(.data$value_as_concept_id) & .data$value_as_concept_id != 0
  )

  numeric_stats <- .summarise_numeric_concepts(numeric_concepts) |> dplyr::collect()
  categorical_stats <- .summarise_categorical_concepts(categorical_concepts) |>
    # Convert value_as_number to double to make it compatible with numeric stats
    dplyr::mutate(value_as_number = as.double(.data$value_as_number)) |>
    dplyr::collect()
  dplyr::bind_rows(numeric_stats, categorical_stats)
}

#' @importFrom stats sd
.summarise_numeric_concepts <- function(omop_table) {
  # Calculate mean and sd
  stats <- omop_table |>
    dplyr::group_by(.data$concept_id) |>
    dplyr::summarise(
      mean = mean(.data$value_as_number, na.rm = TRUE),
      sd = sd(.data$value_as_number, na.rm = TRUE)
    )

  # Wrangle output to expected format
  stats |>
    tidyr::pivot_longer(
      cols = c("mean", "sd"),
      names_to = "summary_attribute",
      values_to = "value_as_number"
    )
}

.summarise_categorical_concepts <- function(omop_table) {
  # Calculate frequencies
  frequencies <- omop_table |>
    dplyr::count(.data$concept_id, .data$value_as_concept_id)

  # Wrangle output into the expected format
  frequencies |>
    dplyr::mutate(summary_attribute = "frequency") |>
    dplyr::select(
      "concept_id",
      "summary_attribute",
      value_as_number = "n",
      "value_as_concept_id"
    )
}
