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
    page_sidebar(
      title = "calpyso - PROTOTYPE",
      sidebar = sidebar(
        title = "Filtering options",
        mod_select_concepts_ui("select_concepts"),
        mod_date_range_ui("date_range_1")
      ),
      card(mod_datatable_ui("totals")),
      layout_columns(
        card(mod_monthly_count_ui("monthly_count_1")),
        card(mod_stat_numeric_ui("stat_numeric_1"))
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
      app_title = "calypso"
    )
    # Add here other external resources
    # for example, you can add shinyalert::useShinyalert()
  )
}
