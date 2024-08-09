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
#' @param data A reactive data.frame containing the data from which to select the concepts
#'
#' @return A reactive data.frame filtered on the selected concepts
#'
#' @noRd
mod_select_concepts_server <- function(id, data) {
  stopifnot(is.reactive(data))

  moduleServer(id, function(input, output, session) {
    observeEvent(data(), {
      updateSelectInput(session, "select_concepts", choices = data()$name, selected = data()$name)
    })

    reactive(data()[data()$name %in% input$select_concepts, ])
  })
}
