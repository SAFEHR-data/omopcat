#' The application server-side
#'
#' @param input,output,session Internal parameters for {shiny}.
#'     DO NOT REMOVE.
#' @import shiny
#' @noRd
app_server <- function(input, output, session) {
  # Get the input tables
  concepts_table <- mod_select_bundle_server("select_bundle")
  selected_bundle_id <- mod_bundles_summary_server("bundles")

  # Updated the selected bundle when a row is selected in the bundles table
  mod_update_select_bundle_server("select_bundle", selected_bundle_id)

  # Filter concepts table based on user-selected concepts, showing all by default
  selected_data <- mod_select_concepts_server("select_concepts", concepts_table)

  # Get the selected dates for date-range filtering
  selected_dates <- mod_date_range_server("date_range")

  # Populate the main concepts table in the dashboard with all concepts and their
  # records and patients counts
  # Get the selected row from the datatable as a reactive output
  selected_concept_row <- mod_datatable_server("concepts", selected_dates)

  # Generate the plots based on the selected data
  mod_plots_server("plots", selected_concept_row, selected_dates)

  # Generate the export tab based on the selected data
  mod_export_tab_server("export_tab", selected_data)
}
