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
      card(
        full_screen = TRUE,
        card_header("Distribution of Monthly Records for the selected concepts"),
        plotly::plotlyOutput(ns("monthly_counts"))
      ),
      navset_card_underline(
        full_screen = TRUE,
        title = "Summary Statistics for the selected concepts",
        nav_panel("Numeric concepts", plotOutput(ns("numeric_stats"))),
        nav_panel("Categorical concepts", plotOutput(ns("categorical_stats"))),
      ),
      min_height = 200
    )
  )
}

#' plots Server function
#'
#' Generates the plot of the requested `type`. When no concept is selected, or no data is available,
#' an error is raised.
#'
#' @param selected_concepts Reactive value containing the selected concepts, used for filtering
#' @param selected_dates Optional reactive value if date filtering needs to be applied
#'
#' @noRd
mod_plots_server <- function(id, selected_concepts, selected_dates) {
  stopifnot(is.reactive(selected_concepts))
  stopifnot(is.reactive(selected_dates))

  ## Set default theme for ggplot2
  ggplot2::theme_set(
    ggplot2::theme_minimal(
      base_size = 16
    )
  )

  summary_stats <- get_summary_stats()
  monthly_counts <- get_monthly_counts()
  moduleServer(id, function(input, output, session) {
    selected_concept_ids <- reactive(selected_concepts()$concept_id)

    ## Filter data based on selected concept and date range
    filtered_monthly_counts <- reactive({
      req(length(selected_concept_ids()) > 0)
      req(selected_dates)
      monthly_counts |>
        dplyr::filter(.data$concept_id %in% selected_concept_ids()) |>
        filter_dates(selected_dates())
    })

    filtered_summary_stats <- reactive({
      req(length(selected_concept_ids()) > 0)
      summary_stats |>
        dplyr::filter(.data$concept_id %in% selected_concept_ids())
    })

    output$monthly_counts <- plotly::renderPlotly({
      req(nrow(filtered_monthly_counts()) > 0)
      monthly_count_plot(filtered_monthly_counts())
    })

    output$numeric_stats <- renderPlot({
      req(nrow(filtered_summary_stats()) > 0)
      stat_numeric_plot(filtered_summary_stats())
    })

    output$categorical_stats <- renderPlot({
      req(nrow(filtered_summary_stats()) > 0)
      stat_categorical_plot(filtered_summary_stats())
    })
  })
}
