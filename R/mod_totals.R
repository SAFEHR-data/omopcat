#' totals UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @importFrom shiny NS tagList
mod_totals_ui <- function(id) {
  ns <- NS(id)
  tagList(
    DT::DTOutput(ns("totals"))
  )
}

#' totals Server Functions
#'
#' @noRd
mod_totals_server <- function(id) {
  moduleServer(id, function(input, output, session) {
    totals <- data.frame(
      concept_id = c(2212648, 2617206, 2212406),
      name = c(
        "Blood count; complete (CBC), automated (Hgb, Hct, RBC, WBC and platelet count) and automated differential WBC count",
        "Prostate specific antigen test (psa)",
        "Homocysteine"
      ),
      person_count = c(7080, 960, 10),
      records_per_person = c(4.37, 1.12, 1.06)
    )
    output$totals <- DT::renderDT(totals, selection = list(
      mode = "single",
      selected = 2, target = "row"
    ))
  })
}
