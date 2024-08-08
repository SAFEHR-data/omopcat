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
mod_stat_numeric_server <- function(id) {
  moduleServer(id, function(input, output, session) {
    summary_stat <- data.frame(
      concept = "SELECTED ROW",
      sd = 0.8280661,
      mean = 5.843
    )

    output$stat_numeric_plot <- renderPlot({
      # TODO: move this to a separate function
      stat_numeric_plot(summary_stat)
    })
  })
}
