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
  bundles_table <- all_bundles()
  stopifnot(c("id", "bundle_name") %in% names(bundles_table))

  ## Select bundles based on their ID but use the bundle name for display in the menu
  bundle_choices <- c("all", bundles_table$id)
  names(bundle_choices) <- c("All bundles", bundles_table$bundle_name)

  tagList(
    selectInput(ns("select_bundle"), "Select bundle",
      choices = bundle_choices,
      selected = "all"
    )
  )
}

#' select_bundle Server Functions
#'
#' @description Returns the concepts table for the selected bundle. If the
#' selected bundle is "all", all concepts are returned.
#' The selected bundle is taken from the dropdown menu input, using its `id`.
#'
#' @param bundles_table A data.frame containing the available bundles
#'
#' @return The concept IDs  for the selected bundle as a reactive.
#'
#' @noRd
#'
#' @importFrom rlang .data
mod_select_bundle_server <- function(id) {
  all_concepts <- get_concepts_table()
  all_bundles <- all_bundles()

  moduleServer(id, function(input, output, session) {
    reactive({
      req(input$select_bundle)

      if (input$select_bundle == "all") {
        return(all_concepts$concept_id)
      }

      selected_bundle_id <- input$select_bundle
      domain <- all_bundles[all_bundles$id == selected_bundle_id, ]$domain

      return(get_bundle_concepts(selected_bundle_id, domain))
    })
  })
}

#' update_select_bundle server function
#'
#' @description Updates the selected bundle in the dropdown menu when the reactive
#' input changes.
#'
#' @param selected_bundle_id A reactive character value containing the bundle ID
#' to be selected in the dropdown menu.
#'
#' @noRd
mod_update_select_bundle_server <- function(id, selected_bundle_id) {
  stopifnot(is.reactive(selected_bundle_id))

  moduleServer(id, function(input, output, session) {
    observeEvent(selected_bundle_id(), {
      req(selected_bundle_id())
      updateSelectInput(session, "select_bundle", selected = selected_bundle_id())
    })
  })
}
