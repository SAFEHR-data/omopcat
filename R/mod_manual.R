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
mod_manual_ui <- function(id) {
  card(
    full_screen = TRUE,
    card_title("User Manual"),
    "This is the user manual. It will contain all the information you need to use this app."
  )
}
