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

  selected_data <- mod_select_concepts_server("select_concepts", concepts_table)
  mod_date_range_server("date_range")

  selected_row <- mod_datatable_server("totals", selected_data)
  monthly_counts <- get_monthly_counts()
  mod_monthly_count_server("monthly_count", monthly_counts, selected_row)

  summary_stats <- get_summary_stats()
  mod_stat_numeric_server("stat_numeric", summary_stats, selected_row)

  mod_export_tab_server("export_tab", selected_data)
}
