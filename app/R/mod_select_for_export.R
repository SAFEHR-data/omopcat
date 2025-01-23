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
    actionButton(ns("add_to_export"), "Add current selection to export"),
    value_box("Concepts selected for export", value = textOutput(ns("n_concepts_for_export")))
  )
}

#' select_concepts Server Functions
#'
#' @param selected_concept_ids A reactive integer vector of concept IDs
#'
#' @return A reactive character vector of selected concept IDs
#'
#' @noRd
mod_select_for_export_server <- function(id, selected_concept_ids) {
  stopifnot(is.reactive(selected_concept_ids))

  moduleServer(id, function(input, output, session) {
    # Store selection in a reactiveValues object so we can update and return it later
    r <- reactiveValues()
    # Initialise empty character vector, note that this will guarantee current_selection
    # will remain a character as anything appended to it will be coerced to character
    r$current_selection <- character()

    # When the add_to_export button is clicked, update the selected_concepts data
    observeEvent(input$add_to_export, {
      r$current_selection <- unique(c(
        r$current_selection,
        selected_concept_ids()
      ))
    })

    output$n_concepts_for_export <- renderText({
      length(r$current_selection)
    })

    return(reactive(r$current_selection))
  })
}
