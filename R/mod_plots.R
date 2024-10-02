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
  tagList(
    layout_columns(
      card(plotOutput(ns("monthly_counts")), height = 250),
      card(plotOutput(ns("summary_stats")), height = 250)
    )
  )
}

#' plots Server function
#'
#' Generates the plot of the requested `type`. When no concept is selected, or no data is available,
#' an error is raised.
#'
#' @param data `data.frame` containing the data to be plotted.
#' @param selected_concept Reactive value containing the selected concept, used for filtering
#' @param selected_dates Optional reactive value if date filtering needs to be applied
#' @param type The type of plot to be generated.
#'
#' @noRd
mod_plots_server <- function(id, selected_concept, selected_dates) {
  stopifnot(is.reactive(selected_concept))
  stopifnot(is.reactive(selected_dates))

  moduleServer(id, function(input, output, session) {
    selected_concept_id <- reactive(selected_concept()$concept_id)
    selected_concept_name <- reactive(selected_concept()$concept_name)

    ## Filter data based on selected concept and date range
    monthly_counts <- reactive({
      req(length(selected_concept_name()) > 0)
      req(selected_dates)
      get_monthly_counts() |>
        dplyr::filter(.data$concept_id == selected_concept_id()) |>
        filter_dates(selected_dates())
    })

    summary_stats <- reactive({
      req(length(selected_concept_name()) > 0)
      get_summary_stats() |>
        dplyr::filter(.data$concept_id == selected_concept_id())
    })

    output$monthly_counts <- renderPlot({
      req(nrow(monthly_counts()) > 0)
      monthly_count_plot(monthly_counts(), selected_concept_name())
    })

    output$summary_stats <- renderPlot({
      req(nrow(summary_stats()) > 0)
      summary_stat_plot(summary_stats(), selected_concept_name())
    })
  })
}
