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
    # Create initial 0-row data.frame with same structure as selected_concepts
    r <- reactiveValues()
    r$current_selection <- isolate(selected_concepts()[0, ])

    # When the add_to_export button is clicked, update the selected_concepts data
    observeEvent(input$add_to_export, {
      r$current_selection <- dplyr::full_join(
        r$current_selection,
        selected_concepts(),
        by = names(r$current_selection)
      )
    })

    output$concepts_for_export <- renderText({
      nrow(r$current_selection)
    })

    return(reactive(r$current_selection))
  })
}
