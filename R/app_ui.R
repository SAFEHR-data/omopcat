#' The application User-Interface
#'
#' @param request Internal parameter for `{shiny}`.
#'     DO NOT REMOVE.
#' @import shiny shinydashboard
#' @noRd
app_ui <- function(request) {
  tagList(
    # Leave this function for adding external resources
    golem_add_external_resources(),

    # The UI logic
    dashboardPage(
      dashboardHeader(title = "calypso"),
      dashboardSidebar(
        title = "Filtering",
        mod_timeframe_ui("timeframe_1")
      ),
      dashboardBody(
        fluidRow(
          box(mod_totals_ui("totals_1"), width = 12),
          box(mod_monthly_count_ui("monthly_count_1"), height = 250),
          box(mod_stat_numeric_ui("stat_numeric_1"), height = 250)
        )
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
