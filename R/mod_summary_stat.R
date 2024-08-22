#' summary_stat UI Function
#'
#' Displays the boxplot of the summary statistics for a numeric concept.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @importFrom shiny NS tagList
mod_summary_stat_ui <- function(id) {
  ns <- NS(id)
  tagList(
    plotOutput(ns("summary_stat_plot"), height = 250)
  )
}

#' summary_stat Server Functions
#'
#' Generates the boxplot of the summary statistics for a numeric concept.
#' When no concept was selected, an empty plot is returned.
#'
#' @param data `data.frame` containing the data to be plotted.
#' @param selected_concept Reactive value containing the selected concept, used for filtering
#'
#' @noRd
mod_summary_stat_server <- function(id, data, selected_concept) {
  stopifnot(is.data.frame(data))
  stopifnot(is.reactive(selected_concept))

  moduleServer(id, function(input, output, session) {
    # Filter data based on the selected row
    selected_concept_id <- reactive(selected_concept()$concept_id)
    selected_concept_name <- reactive(selected_concept()$concept_name)

    ## When no row selected, return an empty plot
    filtered_summary_stats <- reactive({
      if (!length(selected_concept_id())) {
        return(NULL)
      }
      data[data$concept_id == selected_concept_id(), ]
    })

    output$summary_stat_plot <- renderPlot({
      ## Return empty plot if no data is selected or if no data is available for the selected concept
      if (is.null(filtered_summary_stats())) return(NULL)
      if (nrow(filtered_summary_stats()) == 0) return(NULL)
      summary_stat_plot(filtered_summary_stats(), selected_concept_name())
    })
  })
}
