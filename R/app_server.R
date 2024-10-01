#' The application server-side
#'
#' @param input,output,session Internal parameters for {shiny}.
#'     DO NOT REMOVE.
#' @import shiny
#' @noRd
app_server <- function(input, output, session) {
  concepts_table <- mod_select_bundle_server("select_bundle")

  selected_data <- mod_select_concepts_server("select_concepts", concepts_table)
  selected_concept_row <- mod_datatable_server("concepts", selected_data)
  selected_dates <- mod_date_range_server("date_range")

  mod_plots_server("plots", selected_concept_row, selected_dates)
  mod_export_tab_server("export_tab", selected_data)
}
