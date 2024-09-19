#' datatable UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @importFrom shiny NS tagList
mod_datatable_ui <- function(id) {
  ns <- NS(id)
  tagList(
    DT::DTOutput(ns("datatable"))
  )
}

#' datatable Server Functions
#'
#' @param data A reactive data.frame containing the data to be displayed
#'
#' @return The selected row as a reactive object
#'
#' @noRd
mod_datatable_server <- function(id, data, selected_dates = NULL) {
  stopifnot(is.reactive(data))
  stopifnot(is.reactive(selected_dates) || is.null(selected_dates))

  moduleServer(id, function(input, output, session) {

    output$datatable <- DT::renderDT(selected_data_plus_counts(), selection = list(
      mode = "single",
      selected = 1,
      target = "row"
    ))

    #use selected dates to calc num patients and records per concept
    ##join onto selected_data
    ##start with mean records_per_person
    ##later we need to add record_count & calc person_count=record_count/mean(records_per_person)

    monthly_counts <- get_monthly_counts()

    selected_data_plus_counts <- reactive({
      filter_dates(monthly_counts, selected_dates()) |>
        group_by(concept_id) |>
        summarise(#patients = round(sum(record_count)/mean(records_per_person)),
                  records_per_person = mean(records_per_person)) |>
        dplyr::right_join(data(), by = "concept_id")
    })

    reactive(selected_data_plus_counts()[input$datatable_rows_selected, ])


  })
}
