#' datatable UI Function
#'
#' @description The UI component to display the datatable.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @importFrom shiny NS tagList
mod_datatable_ui <- function(id) {
  ns <- NS(id)
  tagList(
    card(
      card_header(
        class = "d-flex justify-content-between",
        span(
          "Concepts overview",
          tooltip(
            bsicons::bs_icon("exclamation-circle"),
            .low_frequency_disclaimer()
          )
        ),
        tooltip(
          actionButton(ns("clear_rows"), icon("broom")),
          "Clear selected rows"
        )
      ),
      DT::DTOutput(ns("datatable")),
      min_height = 650
    )
  )
}

.low_frequency_disclaimer <- function() {
  glue::glue(
    "Note: to ensure patients are not identifiable, counts",
    " below {Sys.getenv('LOW_FREQUENCY_THRESHOLD')}",
    " are converted to {Sys.getenv('LOW_FREQUENCY_REPLACEMENT')}."
  )
}

#' datatable Server Functions
#'
#' @description Generates a `DT::datatable` with the concepts and their counts for the selected
#' date range. The datatable allows the user to select a concept by clicking its row.
#' The selected row is returned as a reactive object.
#' Updates the selected rows in the datatable based on the concept IDs
#' provided. This is used to automatically select rows when a user selects concepts
#' in another part of the app.
#'
#' @param selected_dates A reactive object containing the selected dates
#' @param bundle_concepts A reactive object containing the concept IDs to select as
#' an integer vector.
#'
#' @return The selected row as a reactive object
#'
#' @noRd
mod_datatable_server <- function(id, selected_dates, bundle_concepts) {
  stopifnot(is.reactive(selected_dates))
  stopifnot(is.reactive(bundle_concepts))

  all_concepts <- get_concepts_table()
  monthly_counts <- get_monthly_counts()

  moduleServer(id, function(input, output, session) {
    concepts_with_counts <- reactive({
      join_counts_to_concepts(all_concepts, monthly_counts, selected_dates()) |>
        # Reorder and select the columns we want to display
        dplyr::select(
          "concept_id", "concept_name",
          "total_records", "mean_persons",
          "domain_id", "vocabulary_id", "concept_class_id"
        )
    })
    output$datatable <- DT::renderDT(concepts_with_counts(),
      fillContainer = TRUE,
      rownames = FALSE,
      colnames = c(
        "ID" = "concept_id",
        "Name" = "concept_name",
        "Total Records" = "total_records",
        "Average Patients" = "mean_persons",
        "Domain ID" = "domain_id",
        "Vocabulary ID" = "vocabulary_id",
        "Concept Class ID" = "concept_class_id"
      ),
      selection = list(mode = "multiple", selected = 1, target = "row")
    )

    ## Automatically select rows in datatable when a bundle is selected
    row_indices <- reactive({
      selected_concept_ids <- bundle_concepts()
      match(selected_concept_ids, concepts_with_counts()$concept_id)
    })
    datatable_proxy <- DT::dataTableProxy("datatable", session = session, deferUntilFlush = FALSE)
    observeEvent(row_indices(), {
      DT::selectRows(datatable_proxy, selected = row_indices())
    })
    observeEvent(input$clear_rows, {
      DT::selectRows(datatable_proxy, selected = NULL) # nocov
    })

    reactive(concepts_with_counts()[input$datatable_rows_selected, ])
  })
}

## Use selected dates to calculate number of patients and records per concept
## and join onto selected_data
join_counts_to_concepts <- function(concepts, monthly_counts, selected_dates) {
  summarised_counts <- monthly_counts |>
    filter_dates(selected_dates) |>
    dplyr::group_by(.data$concept_id) |>
    dplyr::summarise(
      # round to avoid decimal values in in total_records because of low-req replacement
      total_records = sum(round(.data$record_count)),
      mean_persons = round(mean(.data$person_count, na.rm = TRUE), 2),
      mean_records_per_person = round(mean(.data$records_per_person, na.rm = TRUE), 2)
    )
  # Use inner_join so we only keep concepts for which we have counts in the selected dates
  dplyr::inner_join(concepts, summarised_counts, by = "concept_id")
}
