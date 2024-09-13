#' dropdown list UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @importFrom shiny NS tagList
mod_dropdown_list_ui <- function(id) {
  ns <- NS(id)
  tagList(
    selectInput(ns("select_bundle"), "Select bundle", choices = NULL)
  )
}

#' dropdown list Server Functions
#'
#' @param data A reactive data.frame containing the data to be displayed
#'
#' @return The selected row as a reactive object
#'
#' @noRd
mod_dropdown_list_server <- function(id, bundles_table) {
  stopifnot("concept_name" %in% names(bundles_table))

  moduleServer(id, function(input, output, session) {
    bundles_table <- reactiveVal(bundles_table)
    observeEvent(bundles_table(), {
      updateSelectInput(session, "select_bundle",
                        choices = bundles_table()$concept_name
      )
    })
    reactive(bundles_table()[bundles_table()$concept_name %in% input$select_bundle, ])
  })
}
