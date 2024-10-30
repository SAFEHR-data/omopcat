#' The application server-side
#'
#' @param input,output,session Internal parameters for {shiny}.
#'     DO NOT REMOVE.
#' @import shiny
#' @noRd
app_server <- function(input, output, session) {
  bundle_concepts <- mod_select_bundle_server("select_bundle")
  selected_bundle_id <- mod_bundles_summary_server("bundles")

  # Updated the selected bundle when a row is selected in the bundles table
  mod_update_select_bundle_server("select_bundle", selected_bundle_id)

  # Get the selected dates for date-range filtering
  selected_dates <- mod_date_range_server("date_range")

  # Populate the main concepts table in the dashboard with all concepts and their
  # records and patients counts
  # Get the selected row from the datatable as a reactive output
  selected_concepts <- mod_datatable_server("concepts", selected_dates, bundle_concepts)

  # Generate the plots based on the selected data
  mod_plots_server("plots", selected_concepts, selected_dates)

  # Update data to be exported with the selected concepts
  data_for_export <- mod_select_for_export_server("select_for_export", selected_concepts)

  # Generate the export tab based on the selected data
  mod_export_tab_server("export_tab", data_for_export)
}
