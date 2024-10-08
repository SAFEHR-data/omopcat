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
  card(
    full_screen = TRUE,
    card_title(""),
    fluidRow(
      includeMarkdown(app_sys("app/www/help_tab.md"))
    )
  )
}
