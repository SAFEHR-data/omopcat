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
  ns <- NS(namespace)
  tagList(
    shiny::p(tagList(
      shiny::textOutput(ns("row_count"), inline = TRUE),
      shiny::span("concepts have been selected for export:")
    )),
    shiny::tableOutput(ns("by_domain")),
    shiny::tableOutput(ns("by_concept_class")),
    shiny::tableOutput(ns("by_vocabulary_id"))
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
mod_datatable_server <- function(id, data) {
  stopifnot(is.reactive(data))

  moduleServer(id, function(input, output, session) {
    output$datatable <- DT::renderDT(data(), selection = list(
      mode = "single",
      selected = 1,
      target = "row"
    ))
    output$row_count <- shiny::renderText(nrow(data()))
    output$by_domain <- shiny::renderTable(
      data()
      |> group_by(domain_id)
      |> summarise(concepts = length(concept_id))
    )
    output$by_concept_class <- shiny::renderTable(
      data()
      |> group_by(concept_class_id)
      |> summarise(concepts = length(concept_id))
    )
    output$by_vocabulary_id <- shiny::renderTable(
      data()
      |> group_by(vocabulary_id)
      |> summarise(concepts = length(concept_id))
    )
    reactive(data()[input$datatable_rows_selected, ])
  })
}
