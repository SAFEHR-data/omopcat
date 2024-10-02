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
#' @description Displays all available concepts in a searchable datatable.
#'
#' @return The selected row as a reactive object
#'
#' @noRd
#' @importFrom dplyr group_by summarise
mod_datatable_server <- function(id) {
  all_concepts <- get_concepts_table()

  moduleServer(id, function(input, output, session) {
    output$datatable <- DT::renderDT(all_concepts, selection = list(
      mode = "single",
      selected = 1,
      target = "row"
    ))
    reactive(all_concepts[input$datatable_rows_selected, ])
  })
}
