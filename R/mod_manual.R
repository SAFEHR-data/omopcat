#' manual UI Function
#'
#' @description Defines the User Manual UI.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @importFrom shiny NS tagList
#' @importFrom bslib card card_header
#' @importFrom htmltools includeMarkdown
mod_manual_ui <- function(id) {
  tagList(
    fluidRow(
      tags$div(
        class = "alert alert-warning",
        .low_frequency_disclaimer()
      ),
      includeMarkdown(app_sys("app/www/help_tab.md"))
    )
  )
}
