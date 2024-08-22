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
    ## Filter data based on selected concept and datea range
    selected_concept_id <- reactive(selected_concept()$concept_id)
    selected_concept_name <- reactive(selected_concept()$concept_name)
    filtered_monthly_counts <- reactive({
      req(selected_concept_id())
      req(selected_dates())
      out <- data[data$concept_id == selected_concept_id(), ]
      .filter_dates(out, selected_dates())
    })

    output$monthly_count_plot <- renderPlot({
      ## Return empty plot if no data is selected
      if (is.null(filtered_monthly_counts())) return(NULL)
      monthly_count_plot(filtered_monthly_counts(), selected_concept_name())
    })
  })
}



.filter_dates <- function(monthly_counts, date_range) {
  range_years <- lubridate::year(date_range)
  range_months <- lubridate::month(date_range)

  date_year <- date_month <- NULL
  dplyr::filter(
    monthly_counts,
    date_year >= range_years[1] & date_year <= range_years[2],
    date_month >= range_months[1] & date_month <= range_months[2]
  )
}
