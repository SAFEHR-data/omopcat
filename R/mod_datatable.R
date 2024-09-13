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

#' export datatable UI Function
#'
#' @description A shiny Module.
#'
#' @param namespace namespace to put the table in.
#'
#' @noRd
#'
#' @importFrom shiny NS tagList
mod_exporttable_ui <- function(namespace) {
  shiny::tableOutput(NS(namespace, "exportview"))
}

#' datatable Server Functions
#'
#' @param data A reactive data.frame containing the data to be displayed
#'
#' @return The selected row as a reactive object
#'
#' @noRd
mod_datatable_server <- function(id, data) {
  stopifnot(is.reactive(data))

  moduleServer(id, function(input, output, session) {
    output$datatable <- DT::renderDT(data(), selection = list(
      mode = "single",
      selected = 1,
      target = "row"
    ))
    output$exportview <- shiny::renderTable(data())
    reactive(data()[input$datatable_rows_selected, ])
  })
}
