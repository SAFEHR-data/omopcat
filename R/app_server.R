#' The application server-side
#'
#' @param input,output,session Internal parameters for {shiny}.
#'     DO NOT REMOVE.
#' @import shiny
#' @noRd
app_server <- function(input, output, session) {
  # Get the input tables
  concepts_table <- get_concepts_table()

  selected_data <- mod_select_concepts_server("select_concepts", concepts_table)

  selected_dates <- mod_date_range_server("date_range")

  #use selected dates to calc num patients and records per concept
  ##join counts onto selected_data
  ##start with mean records_per_person
  ##later we need to add record_count & calc person_count=record_count/mean(records_per_person)

  #cat(selected_dates)

  monthly_counts <- get_monthly_counts()

  #Hmmm? filter_dates is giving
  #Error in as.Date.default: do not know how to convert 'date_range' to class “Date”
  df_counts_in_dates <- filter_dates(monthly_counts, selected_dates) |>
    group_by(concept_id) |>
    summarise(records_per_person = mean(records_per_person))

  df_concepts_sel_plus_counts <- selected_data #|>
    #left_join(df_counts_in_dates, by = "concept_id")

  #populate main concepts table
  #selected_row <- mod_datatable_server("totals", selected_data)
  selected_row <- mod_datatable_server("totals", df_concepts_sel_plus_counts)

  mod_plots_server("monthly_counts", selected_row, selected_dates, type = "monthly_counts")
  mod_plots_server("summary_stats", selected_row, type = "summary_stats")

  mod_export_tab_server("export_tab", selected_data)
}
