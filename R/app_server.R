#' The application server-side
#'
#' @param input,output,session Internal parameters for {shiny}.
#'     DO NOT REMOVE.
#' @import shiny
#' @noRd
app_server <- function(input, output, session) {
  # Get the input tables
  concepts_table <- get_concepts_table()
  bundles_table <- get_bundles()

  selected_data <- mod_select_concepts_server("select_concepts", concepts_table)
  mod_date_range_server("date_range")

  selected_concept_row <- mod_datatable_server("concepts", selected_data)
  selected_dates <- mod_date_range_server("date_range")

  mod_plots_server("monthly_counts", selected_concept_row, selected_dates, type = "monthly_counts")
  mod_plots_server("summary_stats", selected_concept_row, type = "summary_stats")

  selected_bundle_row <- mod_datatable_server("bundles", reactiveVal(bundles_table))

  mod_export_tab_server("export_tab", selected_data)
}
