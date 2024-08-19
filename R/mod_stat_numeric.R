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

#' stat_numeric Server Functions
#'
#' Generates the boxplot of the summary statistics for a numeric concept.
#' When no concept was selected, an empty plot is returned.
#'
#' @noRd
mod_stat_numeric_server <- function(id, selected_concept) {
  stopifnot(is.reactive(selected_concept))

  ## Load in summary stats data
  summary_stats <- get_summary_stats()

  moduleServer(id, function(input, output, session) {
    # Filter data based on the selected row
    selected_concept_id <- reactive(selected_concept()$concept_id)
    selected_concept_name <- reactive(selected_concept()$concept_name)

    ## When no row selected, return an empty plot
    filtered_summary_stats <- reactive({
      if (!length(selected_concept_id())) {
        return(NULL)
      }
      summary_stats[summary_stats$concept_id == selected_concept_id(), ]
    })

    output$stat_numeric_plot <- renderPlot({
      ## Return empty plot if no data is selected
      if (is.null(filtered_summary_stats())) return(NULL)
      stat_numeric_plot(filtered_summary_stats(), selected_concept_name())
    })
  })
}
