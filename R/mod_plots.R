#' plots UI Function
#'
#' Shiny module responsible for producing the summary plots
#' UI elements for the dashboard
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @importFrom shiny NS tagList
mod_plots_ui <- function(id) {
  ns <- NS(id)
  # Return as list so we can arrange the UI elements in the main app_ui function
  list(
    monthly_counts = tagList(plotOutput(ns("monthly_count_plot"), height = 250)),
    summary_stats = tagList(plotOutput(ns("summary_stat_plot"), height = 250))
  )
}

#' plots Server Functions
#'
#' @noRd
mod_plots_server <- function(id) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns
    output$monthly_count_plot <- renderPlot({
      input$newplot
      # Add a little noise to the cars data
      cars2 <- cars + rnorm(nrow(cars))
      plot(cars2)
    })
    output$summary_stat_plot <- renderPlot({
      input$newplot
      # Add a little noise to the cars data
      cars2 <- cars + rnorm(nrow(cars))
      plot(cars2)
    })
  })
}
