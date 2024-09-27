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

# use selected dates to calc num patients and records per concept
# join onto selected_data
datatable_plus_counts_server <- function(id, concepts, monthly_counts, selected_dates) {
  moduleServer(id, function(input, output, session) {
    reactive({
      monthly_counts |>
        filter_dates(selected_dates()) |>
        dplyr::group_by(.data$concept_id) |>
        dplyr::summarise(
          records = sum(.data$record_count),
          patients = round(sum(.data$record_count) / mean(.data$records_per_person))
        ) |>
        dplyr::right_join(concepts(), by = "concept_id")
    })
  })
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
  # stopifnot(is.reactive(monthly_counts))
  stopifnot(is.reactive(selected_dates) || is.null(selected_dates))

  moduleServer(id, function(input, output, session) {
    dpc <- datatable_plus_counts_server("sdbc", concepts, monthly_counts, selected_dates)
    output$datatable <- DT::renderDT(dpc(), selection = list(
      mode = "single",
      selected = 1,
      target = "row"
    ))

    reactive(dpc()[input$datatable_rows_selected, ])
  })
}
