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
#' @param concept_ids A reactive vector of concept IDs from which to select the concepts
#'
#' @return A reactive data.frame filtered on the selected concepts
#'
#' @noRd
mod_select_concepts_server <- function(id, concept_ids) {
  all_concepts <- get_concepts_table()

  moduleServer(id, function(input, output, session) {
    observeEvent(concept_ids(), {
      concept_names <- reactive({
        all_concepts$concept_name[all_concepts$concept_id %in% concept_ids()]
      })
      updateSelectInput(session, "select_concepts",
        choices = concept_names(),
        ## Have all present concepts selected by default
        selected = concept_names(),
      )
    })
    reactive(all_concepts[all_concepts$concept_name %in% input$select_concepts, ])
  })
}
