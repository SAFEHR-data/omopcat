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
mod_monthly_count_server <- function(id, data, selected_concept, selected_dates) {
  stopifnot(is.data.frame(data))
  stopifnot(is.reactive(selected_concept))
  stopifnot(is.reactive(selected_dates))

  moduleServer(id, function(input, output, session) {
    ## Filter data based on selected concept and date range
    selected_concept_id <- reactive(selected_concept()$concept_id)
    selected_concept_name <- reactive(selected_concept()$concept_name)
    filtered_monthly_counts <- reactive({
      req(length(selected_concept_name()) > 0)
      out <- data[data$concept_id == selected_concept_id(), ]

      req(selected_dates())
      .filter_dates(out, selected_dates())
    })

    output$monthly_count_plot <- renderPlot({
      ## Return empty plot if no data is selected
      req(filtered_monthly_counts())
      if (nrow(filtered_monthly_counts()) == 0) {
        # TODO: produce warning that no data is available
      }
      monthly_count_plot(filtered_monthly_counts(), selected_concept_name())
    })
  })
}


.filter_dates <- function(monthly_counts, date_range) {
  date_range <- as.Date(date_range)
  if (date_range[2] < date_range[1]) {
    stop("Invalid date range, end date is before start date")
  }

  dates <- lubridate::make_date(year = monthly_counts$date_year, month = monthly_counts$date_month)
  keep_dates <- dplyr::between(dates, date_range[1], date_range[2])
  dplyr::filter(monthly_counts, keep_dates)
}
