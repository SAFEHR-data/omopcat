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
    mod_exportsummary_ui(ns("exportsummary")),
    mod_export_ui(ns("export"))
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
#' @importFrom shiny NS span tableOutput tagList textOutput
#' @importFrom bslib card page_fluid layout_columns
mod_exportsummary_ui <- function(namespace) {
  ns <- NS(namespace)
  tagList(
    p(
      textOutput(ns("concept_count"))
    ),
    layout_columns(
      card(tableOutput(ns("by_domain"))),
      card(tableOutput(ns("by_concept_class"))),
      card(tableOutput(ns("by_vocabulary_id"))),
      col_widths = breakpoints(
        sm = c(7),
        md = c(6, 6),
        lg = c(4, 4, 4)
      ),
      max_height = "200px"
    ),
    card(
      card_header("Preview of the data to be exported"),
      DT::DTOutput(ns("export_data"))
    )
  )
}

#' export_tab Server Functions
#'
#' @param concepts A reactive character vector containing IDs of the concepts to be exported
#'
#' @noRd
mod_export_tab_server <- function(id, concepts) {
  stopifnot(is.reactive(concepts))
  all_concepts <- get_concepts_table()

  moduleServer(id, function(input, output, session) {
    export_data <- reactive(all_concepts[all_concepts$concept_id %in% concepts(), ])
    mod_exportsummary_server("exportsummary", export_data)
    mod_export_server("export", export_data)
  })
}

#' datatable Server Functions
#'
#' @param data A reactive data.frame containing the data to be displayed
#'
#' @return The selected row as a reactive object
#'
#' @noRd
#' @importFrom dplyr group_by summarise n_distinct
mod_exportsummary_server <- function(id, data) {
  stopifnot(is.reactive(data))

  moduleServer(id, function(input, output, session) {
    output$concept_count <- renderText(
      cli::pluralize(
        "{n_distinct(data()$concept_id)} concept{?s} {?has/have} been selected for export:"
      )
    )
    output$by_domain <- renderTable(
      data() |>
        group_by(.data$domain_id) |>
        summarise(concepts = n_distinct(.data$concept_id))
    )
    output$by_concept_class <- renderTable(
      data() |>
        group_by(.data$concept_class_id) |>
        summarise(concepts = n_distinct(.data$concept_id))
    )
    output$by_vocabulary_id <- renderTable(
      data() |>
        group_by(.data$vocabulary_id) |>
        summarise(concepts = n_distinct(.data$concept_id))
    )
    output$export_data <- DT::renderDT(
      data(),
      selection = "none",
      rownames = FALSE,
      options = list(pageLength = 5)
    )
  })
}
