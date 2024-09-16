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
    selectInput(ns("select_bundle"), "Select bundle", choices = NULL, multiple = FALSE)
  )
}

#' dropdown list Server Functions
#'
#' @param data A reactive data.frame containing the data to be displayed
#'
#' @return The selected row as a reactive object
#'
#' @noRd
#'
#' @importFrom rlang .data
mod_dropdown_list_server <- function(id, bundles_table) {
  stopifnot("concept_name" %in% names(bundles_table))
  moduleServer(id, function(input, output, session) {
    observeEvent(bundles_table, {
      updateSelectInput(session, "select_bundle", choices = bundles_table$concept_name)
    })
    # bundle <- reactive(bundles_table[bundles_table$concept_name == input$select_bundle, ])
    # reactive({
    #   req(bundle())
    #   dplyr::inner_join(
    #     dplyr::select(get_concepts_table(), .data$concept_id, .data$concept_name),
    #     get_bundle_concepts_table(bundle()$id, bundle()$domain),
    #     join_by(concept_id)
    #   )
    # })
    reactive(bundles_table[bundles_table$concept_name == input$select_bundle, ])
  })
}
