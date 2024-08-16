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

# TODO: this module needs unit tests

#' stat_numeric Server Functions
#'
#' @noRd
mod_stat_numeric_server <- function(id, summary_stats) {
  stopifnot(is.reactive(summary_stats))

  moduleServer(id, function(input, output, session) {
    output$stat_numeric_plot <- renderPlot({
      stat_numeric_plot(summary_stats())
    })
  })
}
