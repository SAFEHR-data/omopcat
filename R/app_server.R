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
  mod_date_range_server("date_range")

  selected_row <- mod_datatable_server("totals", selected_data)

  # TODO: would it make sense to have just one plotting module that handles data filtering and
  # produces both plots?

  ## Filter monthly_counts and summary_stats based on selected_row
  selected_concept_id <- reactive(selected_row()$concept_id)
  selected_concept_name <- reactive(selected_row()$concept_name)
  filtered_monthly_counts <- reactive({
    if (!length(selected_concept_id())) {
      return(NULL)
    }
    monthly_counts[monthly_counts$concept_id == selected_concept_id(), ]
  })
  mod_monthly_count_server("monthly_count", filtered_monthly_counts, selected_concept_name)
  mod_stat_numeric_server("stat_numeric", selected_row)

  mod_export_tab_server("export_tab", selected_data)
}
