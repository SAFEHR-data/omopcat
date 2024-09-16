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

#' export datatable UI Function
#'
#' @description A shiny Module.
#'
#' @param namespace namespace to put the table in.
#'
#' @noRd
#'
#' @importFrom shiny NS tagList
mod_exporttable_ui <- function(namespace) {
  ns <- NS(namespace)
  tagList(
    shiny::p("Summary of the table to be exported:"),
    shiny::tableOutput(ns("exportview"))
  )
}

summarize_column <- function(df_col) {
  max_display_explicitly <- 9
  display_initial <- 5
  vals <- unique(df_col)
  n <- length(vals)
  if (n <= max_display_explicitly) {
    return(paste(vals, collapse = ", "))
  }
  # Too many values to list comfortably
  paste0(
    paste(vals[1:display_initial], collapse = ", "),
    "... and ",
    n - display_initial,
    " others"
  )
}

summarize_dataframe <- function(df) {
  summaries <- apply(df, 2, summarize_column)
  df <- data.frame(columns = names(df), uniques = summaries)
  colnames(df) <- c("Column", "Unique values in this column")
  df
}

#' datatable Server Functions
#'
#' @param data A reactive data.frame containing the data to be displayed
#'
#' @return The selected row as a reactive object
#'
#' @noRd
mod_datatable_server <- function(id, data) {
  stopifnot(is.reactive(data))

  moduleServer(id, function(input, output, session) {
    output$datatable <- DT::renderDT(data(), selection = list(
      mode = "single",
      selected = 1,
      target = "row"
    ))
    output$exportview <- shiny::renderTable(summarize_dataframe(data()))
    reactive(data()[input$datatable_rows_selected, ])
  })
}
