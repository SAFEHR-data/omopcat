#' select_concepts UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @importFrom shiny NS tagList
mod_select_for_export_ui <- function(id) {
  ns <- NS(id)
  tagList(
    actionButton(ns("add_to_export"), "Add selection to export"),
    value_box("Concepts selected for export", value = textOutput(ns("n_concepts_for_export")))
  )
}

#' select_concepts Server Functions
#'
#' @param concepts_data A reactive data frame of concepts data
#'
#' @return A reactive character vector of selected concept IDs
#'
#' @noRd
mod_select_for_export_server <- function(id, concepts_data) {
  stopifnot(is.reactive(concepts_data))

  moduleServer(id, function(input, output, session) {
    # Store selection in a reactiveValues object so we can update and return it later
    r <- reactiveValues()
    r$current_selection <- character()

    # When the add_to_export button is clicked, update the selected_concepts data
    observeEvent(input$add_to_export, {
      r$current_selection <- unique(c(
        r$current_selection,
        concepts_data()$concept_id
      ))
    })

    output$n_concepts_for_export <- renderText({
      length(r$current_selection)
    })

    return(reactive(r$current_selection))
  })
}
