#' datatable UI Function
#'
#' @description A shiny Module.
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

# FIXME: update docs
#' datatable Server Functions
#'
#' @param data A reactive data.frame containing the data to be displayed
#'
#' @return The selected row as a reactive object
#'
#' @noRd
#' @importFrom dplyr group_by summarise
mod_datatable_server <- function(id, concepts, monthly_counts, selected_dates = NULL) {
  stopifnot(is.reactive(concepts))
  stopifnot(is.data.frame(monthly_counts))
  stopifnot(is.reactive(selected_dates) || is.null(selected_dates))

  moduleServer(id, function(input, output, session) {
    concepts_with_counts <- reactive({
      join_counts_to_concepts(concepts(), monthly_counts, selected_dates())
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
