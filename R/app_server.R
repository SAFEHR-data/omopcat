#' The application server-side
#'
#' @param input,output,session Internal parameters for {shiny}.
#'     DO NOT REMOVE.
#' @import shiny
#' @noRd
app_server <- function(input, output, session) {

  # TODO: to be replaced by real data, which should be reactive so it responds to filtering options
  mock_data <- data.frame(
    concept_id = c(2212648, 2617206, 2212406),
    name = c(
      "Blood count; complete (CBC), automated (Hgb, Hct, RBC, WBC and platelet count) and automated differential WBC count",
      "Prostate specific antigen test (psa)",
      "Homocysteine"
    ),
    person_count = c(7080, 960, 10),
    records_per_person = c(4.37, 1.12, 1.06)
  )
  mock_data <- reactiveVal(mock_data)

  mod_select_concepts_server("select_concepts", mock_data)
  mod_timeframe_server("timeframe_1")
  mod_datatable_server("totals", mock_data)
  mod_monthly_count_server("monthly_count_1")
  mod_stat_numeric_server("stat_numeric_1")
}
