#' select_bundle UI Function
#'
#' @description Provides a dropdown menu to select a bundle. By default, the
#' selected bundle is "all", which results in all concepts being shown.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @importFrom shiny NS tagList
mod_select_bundle_ui <- function(id) {
  ns <- NS(id)
  bundles_table <- get_bundles_table()
  stopifnot("concept_name" %in% names(bundles_table))

  tagList(
    selectInput(ns("select_bundle"), "Select bundle",
      choices = c("all", bundles_table$concept_name),
      selected = "all"
    )
  )
}

#' select_bundle Server Functions
#'
#' @description Returns the concepts table for the selected bundle. If the
#' selected bundle is "all", all concepts are returned.
#'
#' @param bundles_table A data.frame containing the available bundles
#'
#' @return The concepts table for the selected bundle as a reactive data.frame.
#'
#' @noRd
#'
#' @importFrom rlang .data
mod_select_bundle_server <- function(id, bundles_table) {
  moduleServer(id, function(input, output, session) {
    reactive({
      req(input$select_bundle)

      if (input$select_bundle == "all") {
        return(get_concepts_table())
      }

      bundle <- bundles_table[bundles_table$concept_name == input$select_bundle, ]
      dplyr::inner_join(
        get_concepts_table(),
        dplyr::select(get_bundle_concepts_table(bundle$id, bundle$domain), .data$concept_id),
        dplyr::join_by("concept_id")
      )
    })
  })
}
