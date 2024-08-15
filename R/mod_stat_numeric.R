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
mod_stat_numeric_server <- function(id, selected_row) {
  stopifnot(is.reactive(selected_row))

  moduleServer(id, function(input, output, session) {
    selected_concept <- reactive(selected_row()$name)
    summary_stat <- reactive({
      # When no row is selected, show nothing
      if (!length(selected_concept())) return(NULL)

      data.frame(
        concept = selected_concept(),
        sd = 0.8280661,
        mean = 5.843
      )
    })

    output$stat_numeric_plot <- renderPlot({
      if (!is.null(summary_stat())) {
        stat_numeric_plot(summary_stat())
      }
    })
  })
}
