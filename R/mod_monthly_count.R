#' monthly_count UI Function
#'
#' Displays the monthly count plot.
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
#' Generates the monthly count plot for a given concept. When no concept was selected,
#' an empty plot is generated.
#'
#' @param data `data.frame` containing the data to be plotted.
#' @param selected_concept Reactive value containing the selected concept, used for filtering
#'
#' @noRd
mod_monthly_count_server <- function(id, data, selected_concept) {
  stopifnot(is.data.frame(data))
  stopifnot(is.reactive(selected_concept))


  moduleServer(id, function(input, output, session) {
    ## Filter data based on selected_row
    selected_concept_id <- reactive(selected_concept()$concept_id)
    selected_concept_name <- reactive(selected_concept()$concept_name)
    filtered_monthly_counts <- reactive({
      if (!length(selected_concept_id())) {
        return(NULL)
      }
      data[data$concept_id == selected_concept_id(), ]
    })
    output$monthly_count_plot <- renderPlot({
      ## Return empty plot if no data is selected or if no data is available for the selected concept
      if (is.null(filtered_monthly_counts())) return(NULL)
      if (nrow(filtered_monthly_counts()) == 0) return(NULL)
      monthly_count_plot(filtered_monthly_counts(), selected_concept_name())
    })
  })
}
