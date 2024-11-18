#' Generate the `omopcat_concepts` table
#'
#' @param cdm A [`CDMConnector`] object, e.g. from [`CDMConnector::cdm_from_con()`]
#' @param concept_ids A vector of concept IDs
#'
#' @return A `data.frame` with the monthly counts
#' @keywords internal
generate_concepts <- function(cdm, concept_ids) {
  # Extract columns from concept table
  cdm$concept |>
    dplyr::filter(.data$concept_id %in% concept_ids) |>
    dplyr::filter(.data$concept_id != 0) |> # remove "no matching concept" instances
    dplyr::select(
      "concept_id",
      "concept_name",
      "vocabulary_id",
      "domain_id",
      "concept_class_id",
      "standard_concept",
      "concept_code"
    ) |>
    dplyr::collect()
}
