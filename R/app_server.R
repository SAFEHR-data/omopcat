#' The application server-side
#'
#' @param input,output,session Internal parameters for {shiny}.
#'     DO NOT REMOVE.
#' @import shiny
#' @noRd
app_server <- function(input, output, session) {
  mod_timeframe_server("timeframe_1")
  mod_totals_server("totals_1")
  mod_monthly_count_server("monthly_count_1")
  mod_stat_numeric_server("stat_numeric_1")
}
