#' select_concepts UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @importFrom shiny NS tagList
mod_select_for_export_ui <- function(id) {
  ns <- NS(id)
  tagList(
    actionButton(ns("add_to_export"), "Add current selection to export"),
    value_box("Concepts selected for export", value = textOutput(ns("n_concepts_for_export"))),
    div(class = "small text-muted", textOutput(ns("extract_info")))
  )
}

#' select_concepts Server Functions
#'
#' @param selected_concept_ids A reactive integer vector of concept IDs
#'
#' @return A reactive character vector of selected concept IDs
#'
#' @noRd
mod_select_for_export_server <- function(id, selected_concept_ids, selected_dates = reactive(NULL)) {
  stopifnot(is.reactive(selected_concept_ids))
  stopifnot(is.reactive(selected_dates))

  monthly_counts <- get_monthly_counts()

  moduleServer(id, function(input, output, session) {
    # Store selection in a reactiveValues object so we can update and return it later
    r <- reactiveValues()
    # Initialise empty character vector, note that this will guarantee current_selection
    # will remain a character as anything appended to it will be coerced to character
    r$current_selection <- character()

    # When the add_to_export button is clicked, update the selected_concepts data
    observeEvent(input$add_to_export, {
      r$current_selection <- unique(c(
        r$current_selection,
        selected_concept_ids()
      ))
    })

    output$n_concepts_for_export <- renderText({
      length(r$current_selection)
    })
    output$extract_info <- renderText({
      extract_description(monthly_counts, selected_dates())
    })

    return(reactive(r$current_selection))
  })
}


#' Display the date range for which the selected data corresponds to
#'
#' @param monthly_counts Monthly counts table
#' @param selected_dates A `Date` vector of length 2, or `NULL` for all dates
#'
#' @return A character string
#'
#' @noRd
extract_description <- function(monthly_counts, selected_dates = NULL) {
  if (!is.null(selected_dates)) {
    monthly_counts <- filter_dates(monthly_counts, selected_dates)
  }
  if (nrow(monthly_counts) == 0) {
    return("No data within the selected date range")
  }

  months <- lubridate::make_date(year = monthly_counts$date_year, month = monthly_counts$date_month)
  start <- min(months)
  # Last day of the last month: the first day of the following month, minus one day
  end <- seq(max(months), by = "month", length.out = 2)[2] - 1

  as.character(glue::glue("Data exist from {start} until {end}"))
}
