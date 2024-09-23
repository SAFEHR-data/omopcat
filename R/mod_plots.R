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
#' Generates the plot of the requested `type`. When no concept is selected, the bundle is used
#'
#' @param bundle_concepts Reactive value containing the concepts for the current bundle
#' @param selected_concepts Reactive value containing the selected concept, used for filtering
#' @param selected_dates Optional reactive value if date filtering needs to be applied
#' @param type The type of plot to be generated.
#'
#' @noRd
#'
#' @importFrom rlang .data
mod_plots_server <- function(id, bundle_concepts, selected_concepts = NULL, selected_dates = NULL,
                             type = c("monthly_counts", "summary_stats")) {
  stopifnot(is.reactive(bundle_concepts))
  stopifnot(is.reactive(selected_concepts) || is.null(selected_dates))
  stopifnot(is.reactive(selected_dates) || is.null(selected_dates))

  plot_title <- switch(type,
    monthly_counts = "Monthly counts",
    summary_stats = "Summary stats",
    cli::cli_abort("Invalid type: {type}")
  )
  plot_func <- switch(type,
    monthly_counts = monthly_count_plot,
    summary_stats = summary_stat_plot,
    cli::cli_abort("Invalid type: {type}")
  )
  plot_data <- switch(type,
    monthly_counts = get_monthly_counts(),
    summary_stats = get_summary_stats(),
    cli::cli_abort("Invalid type: {type}")
  )

  moduleServer(id, function(input, output, session) {

    ## Filter data based on selected concept and date range
    filtered_data <- reactive({
      req(bundle_concepts())
      out <- plot_data[plot_data$concept_id %in% bundle_concepts()$concept_id, ]
      if (!is.null(selected_concepts)) {
        req(selected_concepts())
        if (nrow(selected_concepts()) > 0) {
          out <- plot_data[plot_data$concept_id %in% selected_concepts()$concept_id, ]
        }
      }
      if (!is.null(selected_dates)) {
        req(selected_dates())
        out <- .filter_dates(out, selected_dates())
      }
      out
    })

    output$summary_plot <- renderPlot({
      ## Return empty plot if no data is available
      req(filtered_data())
      if (nrow(filtered_data()) == 0) {
        stop("No data available for the selected date range")
      }
      plot_func(filtered_data(), plot_title)
    })
  })
}


.filter_dates <- function(x, date_range) {
  date_range <- as.Date(date_range)
  if (date_range[2] < date_range[1]) {
    stop("Invalid date range, end date is before start date")
  }

  dates <- lubridate::make_date(year = x$date_year, month = x$date_month)
  keep_dates <- dplyr::between(dates, date_range[1], date_range[2])
  dplyr::filter(x, keep_dates)
}
