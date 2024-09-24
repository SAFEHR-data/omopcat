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

  selected_data <- mod_select_concepts_server("select_concepts", concepts_table)

  selected_dates <- mod_date_range_server("date_range")

  #populate main concepts table
  selected_row <- mod_datatable_server("totals", selected_data, monthly_counts, selected_dates)

  mod_plots_server("monthly_counts", selected_row, selected_dates, type = "monthly_counts")
  mod_plots_server("summary_stats", selected_row, type = "summary_stats")

  mod_export_tab_server("export_tab", selected_data)
}
