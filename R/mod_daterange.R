#' date_range UI Function
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @importFrom shiny NS tagList
mod_date_range_ui <- function(id) {
  ns <- NS(id)
  min_date <- as.Date("2019-04-01", "%Y-%m-%d")
  max_date <- as.Date("2024-08-01", "%Y-%m-%d")

  tagList(
    sliderInput(
      ns("date_range"), "Date range",
      min = min_date,
      max = max_date,
      value = c(min_date, max_date),
      timeFormat = "%Y-%m"
    )
  )
}

#' date_range Server Functions
#'
#' @return A reactive `Date` vector of length 2 with the selected start and end dates.
#'
#' @noRd
mod_date_range_server <- function(id) {
  moduleServer(id, function(input, output, session) {
    return(reactive({
      input$date_range
    }))
  })
}
