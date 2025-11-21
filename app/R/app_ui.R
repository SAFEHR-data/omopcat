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
      header = tags$head(
        # Add in open graph tags for link previews
        tags$meta(property = "og:title", content = "OMOPCat"),
        tags$meta(property = "og:description", content = "Catalogue of available structured data from UCLH.")
      ),
      fillable = FALSE,
      title = .app_title(),
      sidebar = sidebar(
        title = "Filtering options",
        mod_date_range_ui("date_range"),
        mod_select_bundle_ui("select_bundle"),
        mod_select_for_export_ui("select_for_export")
      ),
      nav_panel(
        title = "Concepts",
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
        title = "Help",
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
  if (!app_prod()) {
    title <- glue::glue("{title} (dev)")
  }
  title
}
