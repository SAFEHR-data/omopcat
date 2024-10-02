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
          records = replace_low_frequencies(.data$records),
          patients = replace_low_frequencies(.data$patients)
        ) |>
        # Reorder and select the columns we want to display
        dplyr::select(
          "concept_id", "concept_name", "records", "patients",
          "domain_id", "vocabulary_id", "concept_class_id"
        )
    })
    output$datatable <- DT::renderDT(concepts_with_counts(), selection = list(
      mode = "single",
      selected = 1,
      target = "row"
    ))

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
      records = sum(.data$record_count),
      patients = round(sum(.data$record_count) / mean(.data$records_per_person))
    )
  # Use inner_join so we only keep concepts for which we have counts in the selected dates
  dplyr::inner_join(concepts, summarised_counts, by = "concept_id")
}
