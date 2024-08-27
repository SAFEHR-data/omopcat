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
  selected_dates <- mod_date_range_server("date_range")

  # TODO: refactor monthly_count and summary_stat modules into a single module?n
  # https://github.com/UCLH-Foundry/omop-data-catalogue/issues/30
  mod_monthly_count_server("monthly_count", monthly_counts, selected_row, selected_dates)
  mod_summary_stat_server("summary_stat", summary_stats, selected_row)

  mod_export_tab_server("export_tab", selected_data)
}
