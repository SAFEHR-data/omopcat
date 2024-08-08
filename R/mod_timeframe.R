#' timeframe UI Function
#'
#' Adds  a slider input to select a date range.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @importFrom shiny NS tagList
mod_timeframe_ui <- function(id) {
  ns <- NS(id)
  tagList(
    sliderInput(ns("slider"), "Date range:",
      min = as.Date("2019-04-01", "%Y-%m-%d"),
      max = as.Date("2024-08-01", "%Y-%m-%d"),
      value = c(as.Date("2019-04-01"), as.Date("2024-08-01")),
      timeFormat = "%Y-%m"
    )
  )
}

#' timeframe Server Functions
#'
#' @noRd
mod_timeframe_server <- function(id) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns
  })
}

