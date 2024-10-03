#' The application User-Interface
#'
#' @param request Internal parameter for `{shiny}`.
#'     DO NOT REMOVE.
#' @import shiny bslib
#' @noRd
app_ui <- function(request) {
  tagList(
    # Leave this function for adding external resources
    golem_add_external_resources(),

    # The UI logic
    page_navbar(
      title = .app_title(),
      sidebar = sidebar(
        title = "Filtering options",
        mod_date_range_ui("date_range"),
        mod_select_bundle_ui("select_bundle"),
        mod_select_concepts_ui("select_concepts")
      ),
      nav_panel(
        title = "Concepts",
        .low_frequency_disclaimer(),
        mod_datatable_ui("concepts"),
        mod_plots_ui("plots")
      ),
      nav_panel(
        title = "Bundles",
        card(
          mod_bundles_summary_ui("bundles"),
          full_screen = TRUE
        )
      ),
      nav_panel(
        title = "Export",
        mod_export_tab_ui("export_tab")
      ),
      nav_panel(
        title = "help",
        mod_manual_ui("manual")
      )
    )
  )
}

#' Add external Resources to the Application
#'
#' This function is internally used to add external
#' resources inside the Shiny application.
#'
#' @import shiny
#' @importFrom golem add_resource_path activate_js favicon bundle_resources
#' @noRd
golem_add_external_resources <- function() {
  add_resource_path(
    "www",
    app_sys("app/www")
  )

  tags$head(
    favicon(),
    bundle_resources(
      path = app_sys("app/www"),
      app_title = "omopcat"
    )
    # Add here other external resources
    # for example, you can add shinyalert::useShinyalert()
  )
}

.app_title <- function() {
  title <- glue::glue('omopcat v{get_golem_config("golem_version")}')
  if (golem::app_dev()) {
    title <- glue::glue("{title} (dev)")
  }
  title
}

.low_frequency_disclaimer <- function() {
  tags$div(
    class = "alert alert-warning",
    glue::glue(
      "Note: to ensure patients are not identifiable, counts",
      " below {Sys.getenv('LOW_FREQUENCY_THRESHOLD')}",
      " are converted to {Sys.getenv('LOW_FREQUENCY_REPLACEMENT')}."
    )
  )
}
