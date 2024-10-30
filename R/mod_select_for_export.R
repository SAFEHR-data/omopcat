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
    value_box("Concepts selected for export", value = textOutput(ns("concepts_for_export")))
  )
}

#' select_concepts Server Functions
#'
#' @param concept_ids A reactive vector of concept IDs from which to select the concepts
#'
#' @return A reactive data.frame filtered on the selected concepts
#'
#' @noRd
mod_select_for_export_server <- function(id, selected_concepts) {
  stopifnot(is.reactive(selected_concepts))

  moduleServer(id, function(input, output, session) {
    # When the add_to_export button is clicked, update the selected_concepts data
    selected_concepts_data <- eventReactive(input$add_to_export, {
      selected_concepts()
    })

    output$concepts_for_export <- renderText({
      nrow(selected_concepts_data())
    })

    return(reactive(selected_concepts_data()))
  })
}
