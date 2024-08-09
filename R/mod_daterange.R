#' date_range UI Function
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @importFrom shiny NS tagList
mod_date_range_ui <- function(id) {
  ns <- NS(id)
  # TODO: decide on which option to keep; dateRangeInput or sliderInput
  tagList(
    dateRangeInput(
      ns("date_range"), "Date range",
      min = as.Date("2019-04-01", "%Y-%m-%d"),
      max = as.Date("2024-08-01", "%Y-%m-%d"),
      start = as.Date("2019-04-01"),
      end = as.Date("2024-08-01"),
      startview = "decade",
      format = "yyyy-mm",
    ),
    sliderInput(ns("slider"), "Date range:",
                min = as.Date("2019-04-01", "%Y-%m-%d"),
                max = as.Date("2024-08-01", "%Y-%m-%d"),
                value = c(as.Date("2019-04-01"), as.Date("2024-08-01")),
                timeFormat = "%Y-%m"
    )
  )
}

#' date_range Server Functions
#'
#' @noRd
mod_date_range_server <- function(id) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns
  })
}

