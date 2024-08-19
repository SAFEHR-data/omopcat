#' stat_numeric UI Function
#'
#' Displays the boxplot of the summary statistics for a numeric concept.
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
#' Generates the boxplot of the summary statistics for a numeric concept.
#' When no concept was selected, an empty plot is returned.
#'
#' @noRd
mod_stat_numeric_server <- function(id, summary_stats) {
  stopifnot(is.reactive(summary_stats))

  moduleServer(id, function(input, output, session) {
    output$stat_numeric_plot <- renderPlot({
      ## Return empty plot if no data is selected
      if (is.null(summary_stats())) return(NULL)
      stat_numeric_plot(summary_stats())
    })
  })
}
