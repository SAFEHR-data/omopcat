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
      card(
        navset_card_underline(
          nav_panel("Numeric concepts", plotOutput(ns("numeric_stats"))),
          nav_panel("Categorical concepts", plotOutput(ns("categorical_stats"))),
        ),
        height = 250
      )
    )
  )
}

#' plots Server function
#'
#' Generates the plot of the requested `type`. When no concept is selected, or no data is available,
#' an error is raised.
#'
#' @param data `data.frame` containing the data to be plotted.
#' @param selected_concepts Reactive value containing the selected concepts, used for filtering
#' @param selected_dates Optional reactive value if date filtering needs to be applied
#' @param type The type of plot to be generated.
#'
#' @noRd
mod_plots_server <- function(id, selected_concepts, selected_dates) {
  stopifnot(is.reactive(selected_concepts))
  stopifnot(is.reactive(selected_dates))

  moduleServer(id, function(input, output, session) {
    selected_concept_ids <- reactive(selected_concepts()$concept_id)

    ## Filter data based on selected concept and date range
    monthly_counts <- reactive({
      req(length(selected_concept_ids()) > 0)
      req(selected_dates)
      get_monthly_counts() |>
        dplyr::filter(.data$concept_id %in% selected_concept_ids()) |>
        filter_dates(selected_dates())
    })

    summary_stats <- reactive({
      req(length(selected_concept_ids()) > 0)
      get_summary_stats() |>
        dplyr::filter(.data$concept_id %in% selected_concept_ids())
    })

    output$monthly_counts <- renderPlot({
      req(nrow(monthly_counts()) > 0)
      monthly_count_plot(
        monthly_counts(),
        plot_title = "Distribution of Monthly Records for the selected concepts"
      )
    })

    output$numeric_stats <- renderPlot({
      req(nrow(summary_stats()) > 0)
      stat_numeric_plot(
        summary_stats(),
        plot_title = "Summary Statistics for the numeric concepts"
      )
    })

    output$categorical_stats <- renderPlot({
      req(nrow(summary_stats()) > 0)
      stat_categorical_plot(
        summary_stats(),
        plot_title = "Summary Statistics for the categorical concepts"
      )
    })
  })
}
