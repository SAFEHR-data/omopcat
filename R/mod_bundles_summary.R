#' bundles_summary UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @importFrom shiny NS tagList
mod_bundles_summary_ui <- function(id) {
  ns <- NS(id)
  # TODO: might be possible to reuse the existing mod_datatable_ui for this
  tagList(
    DT::DTOutput(ns("bundles"))
  )
}

#' bundles_summary Server Functions
#'
#' @noRd
mod_bundles_summary_server <- function(id) {
  moduleServer(id, function(input, output, session) {
    bundle_data <- all_bundles() |>
      dplyr::mutate(
        n_concepts = .n_available_concepts(.data$id, .data$domain)
      )
    output$bundles <- DT::renderDT(
      bundle_data,
      selection = list(mode = "single", selected = 1, target = "row")
    )
  })
}

.n_available_concepts <- function(bundle_id, bundle_domain) {
  ## Count the number of available concepts for a bundle within the input dataset
  available_concepts <- get_concepts_table()$concept_id

  purrr::map2_int(
    bundle_id,
    bundle_domain,
    ~ sum(get_bundle_concepts(.x, .y) %in% available_concepts)
  )
}
