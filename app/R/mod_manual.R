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
  # Render the Rmarkdown file to a temporary markdown file
  help_path <- file.path(tempdir(), "help_tab.md")
  knitr::knit(app_sys("app/help_tab.rmd"), help_path, quiet = TRUE)

  tagList(
    fluidRow(
      tags$div(
        class = "alert alert-warning",
        .low_frequency_disclaimer()
      ),
      htmltools::includeMarkdown(help_path)
    )
  )
}
