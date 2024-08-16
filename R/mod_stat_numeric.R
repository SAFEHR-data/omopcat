#' stat_numeric UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @importFrom shiny NS tagList
mod_stat_numeric_ui <- function(id) {
  ns <- NS(id)
  tagList(
    plotOutput(ns("stat_numeric_plot"), height = 250)
  )
}

#' stat_numeric Server Functions
#'
#' @noRd
mod_stat_numeric_server <- function(id, summary_stats, selected_row) {
  stopifnot(is.data.frame(summary_stats))
  stopifnot(is.reactive(selected_row))

  moduleServer(id, function(input, output, session) {
    selected_concept_id <- reactive(selected_row()$concept_id)
    summary_stats <- reactive({
      # When no row is selected, show nothing
      if (!length(selected_concept())) {
        return(NULL)
      }
      summary_stats()[summary_stats()$concept_id == selected_concept_id(), ]
    })

    output$stat_numeric_plot <- renderPlot({
      stat_numeric_plot(summary_stats())
    })
  })
}
