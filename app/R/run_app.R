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
  ...
) {
  # Synchronise environment variable settings and golem options for running in prod
  if (app_prod()) {
    .check_envvars("OMOPCAT_DATA_PATH")
  }

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

#' Determine if the application is running in production mode
#'
#' Relies only on the `GOLEM_CONFIG_ACTIVE` environment variable.
#' This is a replacement for [`golem::app_prod()`], which relies on
#' the `"golem.app.prod"` option, but not on the environment variable.
#' @noRd
app_prod <- function() {
  return(get_golem_config("app_prod"))
}

.check_envvars <- function(required) {
  missing <- Sys.getenv(required) == ""
  if (any(missing)) {
    cli::cli_abort(c(
      "x" = "Environment variable{?s} {.envvar {required[missing]}} not set",
      "i" = "Make sure to define the environment variables (e.g. in a local {.file .Renviron} file)"
    ), call = rlang::caller_env())
  }
}
