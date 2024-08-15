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

#' monthly_count Server Functions
#'
#' @noRd
mod_monthly_count_server <- function(id, selected_row) {
  stopifnot(is.reactive(selected_row))

  moduleServer(id, function(input, output, session) {
    # TODO:: to be replaced with the actual data
    monthly_count <- data.frame(
      date = c("2020-01", "2020-02", "2020-03", "2020-04"),
      record_count = c(120, 250, 281, 220)
    )

    # TODO: Filter data on the concept_id from the selected row
    selected_concept <- reactive(selected_row()$name)

    output$monthly_count_plot <- renderPlot({
      monthly_count_plot(monthly_count, selected_concept())
    })
  })
}
