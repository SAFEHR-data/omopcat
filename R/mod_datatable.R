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
  #stopifnot(is.reactive(monthly_counts))
  stopifnot(is.reactive(selected_dates) || is.null(selected_dates))

  moduleServer(id, function(input, output, session) {
    output$datatable <- DT::renderDT(selected_data_plus_counts(), selection = list(
      mode = "single",
      selected = 1,
      target = "row"
    ))


    # use selected dates to calc num patients and records per concept
    # join onto selected_data

    selected_data_plus_counts <- reactive({
        monthly_counts |>
        filter_dates(selected_dates()) |>
        dplyr::group_by(concept_id) |>
        dplyr::summarise(
          records = sum(record_count),
          patients = round(sum(record_count) / mean(records_per_person))
        ) |>
        dplyr::right_join(concepts(), by = "concept_id")
    })

    reactive(selected_data_plus_counts()[input$datatable_rows_selected, ])

  })
}
