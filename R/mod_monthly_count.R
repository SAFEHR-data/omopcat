#' monthly_count UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @importFrom shiny NS tagList
mod_monthly_count_ui <- function(id) {
  ns <- NS(id)
  tagList(
    plotOutput(ns("monthly_count_plot"), height = 250)
  )
}

# TODO: this module needs unit tests

#' monthly_count Server Functions
#'
#' @noRd
mod_monthly_count_server <- function(id, monthly_counts, concept_name) {
  stopifnot(is.reactive(monthly_counts))
  stopifnot(is.reactive(concept_name))

  moduleServer(id, function(input, output, session) {
    output$monthly_count_plot <- renderPlot({
      ## Return empty plot if no data is selected
      if (is.null(monthly_counts())) return(NULL)
      monthly_count_plot(monthly_counts(), concept_name())
    })
  })
}
