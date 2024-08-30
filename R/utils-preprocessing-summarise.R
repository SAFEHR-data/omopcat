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
#' @import dplyr
calculate_monthly_counts <- function(omop_table, concept, date) {
  # Extract year and month from date column
  omop_table <- mutate(omop_table,
    concept_id = {{ concept }},
    date_year = lubridate::year({{ date }}),
    date_month = lubridate::month({{ date }})
  )

  omop_table |>
    group_by(date_year, date_month, concept_id) |>
    summarise(
      person_count = n_distinct(person_id),
      records_per_person = n() / n_distinct(person_id)
    ) |>
    select(
      concept_id,
      date_year,
      date_month,
      person_count,
      records_per_person
    ) |>
    ## Collect in case we're dealing with a database-stored table
    collect()
}
