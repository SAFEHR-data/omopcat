#' export datatable UI Function
#'
#' @description A shiny Module.
#'
#' @param namespace namespace to put the table in.
#'
#' @noRd
#'
#' @importFrom shiny NS span tableOutput tagList textOutput
#' @importFrom bslib card page_fluid layout_columns
mod_exportsummary_ui <- function(namespace) {
  ns <- NS(namespace)
  page_fluid(
    shiny::p(
      textOutput(ns("row_count"), inline = TRUE),
      span("concepts have been selected for export:"),
    ),
    layout_columns(
      card(tableOutput(ns("by_domain"))),
      card(tableOutput(ns("by_concept_class"))),
      card(tableOutput(ns("by_vocabulary_id")))
    )
  )
}

#' export_tab UI Function
#'
#' UI for the export tab.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @importFrom shiny NS tagList
mod_export_tab_ui <- function(id) {
  ns <- NS(id)
  tagList(
    mod_exportsummary_ui(ns("exportsummary")),
    mod_export_ui(ns("export"))
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
mod_exportsummary_server <- function(id, data) {
  stopifnot(is.reactive(data))

  moduleServer(id, function(input, output, session) {
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
  })
}

#' export_tab Server Functions
#'
#' @param data A reactive data.frame containing the data to be exported
#'
#' @noRd
mod_export_tab_server <- function(id, data) {
  stopifnot(is.reactive(data))

  moduleServer(id, function(input, output, session) {
    mod_exportsummary_server("exportsummary", data)
    mod_export_server("export", data)
  })
}
