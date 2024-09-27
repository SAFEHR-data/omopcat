#' The application server-side
#'
#' @param input,output,session Internal parameters for {shiny}.
#'     DO NOT REMOVE.
#' @import shiny
#' @noRd
app_server <- function(input, output, session) {
  # Get the input tables
  concepts_table <- mod_select_bundle_server("select_bundle")
  monthly_counts <- get_monthly_counts()

  # Filter concepts table based on user-selected concepts, showing all by default
  selected_data <- mod_select_concepts_server("select_concepts", concepts_table)

  # Get the selected dates for date-range filtering
  selected_dates <- mod_date_range_server("date_range")

  # Populate the main concepts table in the dashboard with selected concepts and their
  # records and patients counts
  # Get the selected row from the datatable as a reactive output
  selected_row <- mod_datatable_server("concepts", selected_data, monthly_counts, selected_dates)
  
  # Generate the plots based on the selected data
  mod_plots_server("monthly_counts", selected_row, selected_dates, type = "monthly_counts")
  mod_plots_server("summary_stats", selected_row, type = "summary_stats")

  # Generate the export tab based on the selected data
  mod_export_tab_server("export_tab", selected_data)
}
