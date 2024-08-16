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
mod_monthly_count_server <- function(id, monthly_counts, selected_row) {
  stopifnot(is.data.frame(monthly_counts))
  stopifnot(is.reactive(selected_row))

  moduleServer(id, function(input, output, session) {
    selected_concept_id <- reactive(selected_row()$concept_id)
    selected_concept_name <- reactive(selected_row()$concept_name)
    monthly_counts <- reactive({
      # When no row is selected, show nothing
      if (!length(selected_concept_id())) return(NULL)
      monthly_counts()[monthly_counts()$concept_id == selected_concept_id(), ]
    })

    output$monthly_count_plot <- renderPlot({
      monthly_count_plot(monthly_counts(), selected_concept_name())
    })
  })
}
