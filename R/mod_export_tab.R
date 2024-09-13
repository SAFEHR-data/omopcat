#' export_tab UI Function
#'
#' UI for the export tab.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @importFrom shiny NS tagList
mod_export_tab_ui <- function(id) {
  ns <- NS(id)
  tagList(
    mod_exporttable_ui(ns("datatable")),
    mod_export_ui(ns("export"))
  )
}

#' export_tab Server Functions
#'
#' @param data A reactive data.frame containing the data to be exported
#'
#' @noRd
mod_export_tab_server <- function(id, data) {
  stopifnot(is.reactive(data))

  moduleServer(id, function(input, output, session) {
    mod_datatable_server("datatable", data)
    mod_export_server("export", data)
  })
}
