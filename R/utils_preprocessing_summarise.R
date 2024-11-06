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
#' @export
#' @importFrom dplyr mutate group_by summarise select n n_distinct collect
calculate_monthly_counts <- function(omop_table, concept, date) {
  # Extract year and month from date column
  omop_table <- mutate(omop_table,
    concept_id = {{ concept }},
    date_year = as.integer(lubridate::year({{ date }})),
    date_month = as.integer(lubridate::month({{ date }}))
  )

  omop_table |>
    group_by(.data$date_year, .data$date_month, .data$concept_id) |>
    summarise(
      record_count = n(),
      person_count = n_distinct(.data$person_id),
    ) |>
    # NOTE: Explicitly cast types to avoid unexpected SQL behaviour,
    # otherwise the records_per_person might end up as an int
    # and the *_count vars as int64, which can give problems later
    mutate(
      record_count = as.integer(.data$record_count),
      person_count = as.integer(.data$person_count),
      records_per_person = as.double(.data$record_count) / as.double(.data$person_count)
    ) |>
    select(
      "concept_id",
      "date_year",
      "date_month",
      "record_count",
      "person_count",
      "records_per_person"
    ) |>
    ## Collect in case we're dealing with a database-stored table
    collect()
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
#' @export
#' @importFrom dplyr all_of rename filter collect bind_rows
calculate_summary_stats <- function(omop_table, concept_name) {
  stopifnot(is.character(concept_name))

  omop_table <- rename(omop_table, concept_id = all_of(concept_name))

  ## Avoid "no visible binding" notes
  value_as_number <- value_as_concept_id <- NULL

  numeric_concepts <- filter(omop_table, !is.na(value_as_number))
  # beware CDM docs: NULL=no categorical result, 0=categorical result but no mapping
  categorical_concepts <- filter(omop_table, !is.null(value_as_concept_id) & value_as_concept_id != 0)

  numeric_stats <- .summarise_numeric_concepts(numeric_concepts) |> collect()
  categorical_stats <- .summarise_categorical_concepts(categorical_concepts) |>
    # Convert value_as_number to double to make it compatible with numeric stats
    mutate(value_as_number = as.double(.data$value_as_number)) |>
    collect()
  bind_rows(numeric_stats, categorical_stats)
}

#' @importFrom dplyr group_by summarise
#' @importFrom stats sd
.summarise_numeric_concepts <- function(omop_table) {
  value_as_number <- concept_id <- NULL

  # Calculate mean and sd
  stats <- omop_table |>
    group_by(concept_id) |>
    summarise(mean = mean(value_as_number, na.rm = TRUE), sd = sd(value_as_number, na.rm = TRUE))

  # Wrangle output to expected format
  stats |>
    tidyr::pivot_longer(
      cols = c(mean, sd),
      names_to = "summary_attribute",
      values_to = "value_as_number"
    )
}

#' @importFrom dplyr count mutate select
.summarise_categorical_concepts <- function(omop_table) {
  concept_id <- value_as_concept_id <- summary_attribute <- NULL

  # Calculate frequencies
  frequencies <- omop_table |>
    count(concept_id, value_as_concept_id)

  # Wrangle output into the expected format
  frequencies |>
    mutate(summary_attribute = "frequency") |>
    select(
      concept_id,
      summary_attribute,
      value_as_number = n,
      value_as_concept_id
    )
}
