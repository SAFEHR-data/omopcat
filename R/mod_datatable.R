#' datatable UI Function
#'
#' @description The UI component to display the datatable.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @importFrom shiny NS tagList
mod_datatable_ui <- function(id) {
  ns <- NS(id)
  tagList(
    DT::DTOutput(ns("datatable"))
  )
}

#' datatable Server Functions
#'
#' @description Generates a `DT::datatable` with the concepts and their counts for the selected
#' date range. The datatable allows the user to select a concept by clicking its row.
#' The selected row is returned as a reactive object.
#'
#' @param monthly_counts A data frame containing the monthly counts of records per concept
#' @param selected_dates A reactive object containing the selected dates
#'
#' @return The selected row as a reactive object
#'
#' @noRd
#' @importFrom dplyr group_by summarise
mod_datatable_server <- function(id, selected_dates = NULL) {
  stopifnot(is.reactive(selected_dates) || is.null(selected_dates))

  all_concepts <- get_concepts_table()
  monthly_counts <- get_monthly_counts()

  moduleServer(id, function(input, output, session) {
    concepts_with_counts <- reactive({
      join_counts_to_concepts(all_concepts, monthly_counts, selected_dates()) |>
        # Handle low frequencies
        mutate(
          total_records = replace_low_frequencies(.data$total_records),
          mean_persons = replace_low_frequencies(.data$mean_persons),
          mean_records_per_person = replace_low_frequencies(.data$mean_records_per_person)
        ) |>
        # Reorder and select the columns we want to display
        dplyr::select(
          "concept_id", "concept_name",
          "total_records", "mean_persons", "mean_records_per_person",
          "domain_id", "vocabulary_id", "concept_class_id"
        )
    })
    output$datatable <- DT::renderDT(concepts_with_counts(),
      rownames = FALSE,
      colnames = c(
        "Concept ID" = "concept_id",
        "Concept Name" = "concept_name",
        "Total Records" = "total_records",
        "Average Persons per Month" = "mean_persons",
        "Average Records per Person per Month" = "mean_records_per_person",
        "Domain ID" = "domain_id",
        "Vocabulary ID" = "vocabulary_id",
        "Concept Class ID" = "concept_class_id"
      ),
      selection = list(mode = "multiple", selected = 1, target = "row")
    )

    reactive(concepts_with_counts()[input$datatable_rows_selected, ])
  })
}

## Use selected dates to calculate number of patients and records per concept
## and join onto selected_data
join_counts_to_concepts <- function(concepts, monthly_counts, selected_dates) {
  summarised_counts <- monthly_counts |>
    filter_dates(selected_dates) |>
    dplyr::group_by(.data$concept_id) |>
    dplyr::summarise(
      total_records = sum(.data$record_count),
      mean_persons = mean(.data$person_count, na.rm = TRUE),
      mean_records_per_person = mean(.data$records_per_person, na.rm = TRUE)
    )
  # Use inner_join so we only keep concepts for which we have counts in the selected dates
  dplyr::inner_join(concepts, summarised_counts, by = "concept_id")
}
