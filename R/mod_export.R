#' export UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @importFrom shiny NS tagList
mod_export_ui <- function(id) {
  ns <- NS(id)
  tagList(
    downloadButton(ns("export"), "Export CSV")
  )
}

#' export Server Functions
#'
#' @param data A reactive data.frame containing the data to be exported
#'
#' @noRd
mod_export_server <- function(id, data) {
  stopifnot(is.reactive(data))

  moduleServer(id, function(input, output, session) {
    output$export <- downloadHandler(
      filename = function() {
        paste0("calypso-export-", Sys.Date(), ".csv")
      },
      content = function(file) {
        utils::write.csv(data(), file, row.names = FALSE)
      }
    )
  })
}
