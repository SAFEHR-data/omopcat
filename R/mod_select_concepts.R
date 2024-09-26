#' select_concepts UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @importFrom shiny NS tagList
mod_select_concepts_ui <- function(id) {
  ns <- NS(id)
  tagList(
    selectInput(ns("select_concepts"), "Select concepts", choices = NULL, multiple = TRUE)
  )
}

#' select_concepts Server Functions
#'
#' @param concepts_table A reactive data.frame containing the data from which to select the concepts
#'
#' @return A reactive data.frame filtered on the selected concepts
#'
#' @noRd
mod_select_concepts_server <- function(id, concepts_table) {
  moduleServer(id, function(input, output, session) {
    observeEvent(concepts_table(), {
      stopifnot("concept_name" %in% names(concepts_table()))
      updateSelectInput(session, "select_concepts",
        choices = concepts_table()$concept_name,
        ## Have all present concepts selected by default
        selected = concepts_table()$concept_name
      )
    })
    reactive(concepts_table()[concepts_table()$concept_name %in% input$select_concepts, ])
  })
}
