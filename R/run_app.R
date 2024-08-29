#' Run the Shiny Application
#'
#' @param ... arguments to pass to golem_opts.
#' See `?golem::get_golem_options` for more details.
#' @inheritParams shiny::shinyApp
#'
#' @export
#' @importFrom shiny shinyApp
#' @importFrom golem with_golem_options
run_app <- function(
    onStart = NULL,
    options = list(),
    enableBookmarking = NULL,
    uiPattern = "/",
    ...) {
  # Synchronise environment variable settings and golem options for running in prod
  if (get_golem_config("app_prod")) {
    options("golem.app.prod" = TRUE)
  }
  .check_env()

  with_golem_options(
    app = shinyApp(
      ui = app_ui,
      server = app_server,
      onStart = onStart,
      options = options,
      enableBookmarking = enableBookmarking,
      uiPattern = uiPattern
    ),
    golem_opts = list(...)
  )
}

.check_env <- function() {
  required <- c("CALYPSO_DATA_PATH", "CALYPSO_DB_NAME", "CALYPSO_DB_OMOP_VERSION")
  missing <- required[!required %in% names(Sys.getenv())]
  if (length(missing) > 0) {
    cli::cli_abort("The following environment variables are missing: {.envvar {missing}}")
  }
}
