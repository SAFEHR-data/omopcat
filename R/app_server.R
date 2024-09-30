#' The application server-side
#'
#' @param input,output,session Internal parameters for {shiny}.
#'     DO NOT REMOVE.
#' @import shiny
#' @noRd
app_server <- function(input, output, session) {
  concepts_table <- mod_select_bundle_server("select_bundle")
  selected_bundle_id <- mod_bundles_summary_server("bundles")

  # Updated the selected bundle when a row is selected in the bundles table
  mod_update_select_bundle_server("select_bundle", selected_bundle_id)

  selected_data <- mod_select_concepts_server("select_concepts", concepts_table)
  selected_concept_row <- mod_datatable_server("concepts", selected_data)
  selected_dates <- mod_date_range_server("date_range")

  mod_plots_server("monthly_counts", selected_concept_row, selected_dates, type = "monthly_counts")
  mod_plots_server("summary_stats", selected_concept_row, type = "summary_stats")

  mod_export_tab_server("export_tab", selected_data)
}
