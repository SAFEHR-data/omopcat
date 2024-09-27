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
    plotOutput(ns("summary_plot"), height = 250)
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
mod_plots_server <- function(id, selected_concept, selected_dates = NULL,
                             type = c("monthly_counts", "summary_stats")) {
  stopifnot(is.reactive(selected_concept))
  stopifnot(is.reactive(selected_dates) || is.null(selected_dates))

  plot_func <- switch(type,
    monthly_counts = monthly_count_plot,
    summary_stats = summary_stat_plot,
    cli::cli_abort("Invalid type: {type}")
  )
  data <- switch(type,
    monthly_counts = get_monthly_counts(),
    summary_stats = get_summary_stats(),
    cli::cli_abort("Invalid type: {type}")
  )

  moduleServer(id, function(input, output, session) {
    selected_concept_id <- reactive(selected_concept()$concept_id)
    selected_concept_name <- reactive(selected_concept()$concept_name)

    ## Filter data based on selected concept and date range
    filtered_data <- reactive({
      req(length(selected_concept_name()) > 0)
      out <- data[data$concept_id == selected_concept_id(), ]

      if (!is.null(selected_dates)) {
        req(selected_dates())
        out <- filter_dates(out, selected_dates())
      }
      out
    })

    output$summary_plot <- renderPlot({
      ## Return empty plot if no data is available
      req(filtered_data())
      if (nrow(filtered_data()) == 0) {
        stop("No data available for the selected date range")
      }
      plot_func(filtered_data(), selected_concept_name())
    })
  })
}
