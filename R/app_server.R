#' The application server-side
#'
#' @param input,output,session Internal parameters for {shiny}.
#'     DO NOT REMOVE.
#' @import shiny
#' @noRd
app_server <- function(input, output, session) {
  # Get the input tables
  concepts_table <- get_concepts_table()
  monthly_counts <- get_monthly_counts()
  summary_stats <- get_summary_stats()

  selected_data <- mod_select_concepts_server("select_concepts", mock_data)

  mod_date_range_server("date_range_1")

  selected_row <- mod_datatable_server("totals", selected_data)
  mod_monthly_count_server("monthly_count_1", selected_row)
  mod_stat_numeric_server("stat_numeric_1", selected_row)

  mod_export_tab_server("export_tab", selected_data)
}
