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
#' @param bundles_table A data.frame containing the available bundles
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
    reactive({
      req(input$select_bundle)
      bundle <- bundles_table[bundles_table$concept_name == input$select_bundle, ]
      dplyr::inner_join(
        get_concepts_table(),
        dplyr::select(get_bundle_concepts_table(bundle$id, bundle$domain), .data$concept_id),
        dplyr::join_by("concept_id")
      )
    })
  })
}
