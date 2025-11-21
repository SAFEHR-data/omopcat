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
      min_height = 800
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
#' @return An integer vector of the selected concepts as a reactive object
#'
#' @noRd
mod_datatable_server <- function(id, selected_dates, bundle_concepts) {
  stopifnot(is.reactive(selected_dates))
  stopifnot(is.reactive(bundle_concepts))

  all_concepts <- get_concepts_table()
  monthly_counts <- get_monthly_counts()
  mean_persons_name <-   stringr::str_to_title(
    glue::glue("{Sys.getenv('SUMMARISE_LEVEL', 'monthly')} patients")
    )

  moduleServer(id, function(input, output, session) {
    column_names <- c(
      "ID" = "concept_id",
      "Name" = "concept_name",
      "Total Records" = "total_records",
      "Domain ID" = as.character("domain_id"),
      "Vocabulary ID" = as.character("vocabulary_id"),
      "Concept Class ID" = as.character("concept_class_id")
    )
    column_names[mean_persons_name] <- "mean_persons"

    rv <- reactiveValues(
      concepts_with_counts = join_counts_to_concepts(all_concepts, monthly_counts) |>
        DT::datatable(
          filter = list(position = 'top', clear = FALSE),
          colnames = column_names,
          fillContainer = TRUE,
          selection = list(mode = "multiple", target = "row")
          ) |>
        DT::formatRound(c("Total Records", mean_persons_name), digits = 0),
      selected_concepts = NULL # Keep track of which concepts have been selected
    )

    output$datatable <- DT::renderDT(
      isolate(rv$concepts_with_counts),
    )

    datatable_proxy <- DT::dataTableProxy("datatable")

    ## Keep track of which rows have been selected
    observeEvent(input$datatable_rows_selected, {
      concept_ids <- rv$concepts_with_counts$concept_id
      rv$selected_concepts <- concept_ids[input$datatable_rows_selected]
    })

    ## Recompute the concepts with counts when the selected dates change
    observeEvent(selected_dates(), {
      original_selection <- rv$concepts_with_counts$concept_id[input$datatable_rows_selected]
      new_data <- join_counts_to_concepts(all_concepts, monthly_counts, selected_dates())

      rv$concepts_with_counts <- new_data
      DT::replaceData(datatable_proxy, new_data, clearSelection = "none")

      ## Keep rows selected if they are still in the new table
      rows_to_select <- which(rv$concepts_with_counts$concept_id %in% original_selection)
      rv$selected_concepts <- rv$concepts_with_counts$concept_id[rows_to_select]
      DT::selectRows(datatable_proxy, selected = rows_to_select)
    })

    ## Update the selected rows when the bundle changes and move them to the top of the table
    observeEvent(bundle_concepts(), {
      rows_to_select <- which(rv$concepts_with_counts$concept_id %in% bundle_concepts())
      not_selected <- setdiff(seq_len(nrow(rv$concepts_with_counts)), rows_to_select)
      ordered_data <- rv$concepts_with_counts[c(rows_to_select, not_selected), ]

      ## NOTE: DT::replaceData() requires rownames = TRUE in DT::renderDT() (the default)!
      DT::replaceData(datatable_proxy, ordered_data, clearSelection = "none")

      ## Update the reactive values to reflect the new order
      rv$concepts_with_counts <- ordered_data

      ## The rows to select are now the first n rows where n is the number of rows to select
      new_rows_to_select <- seq_along(rows_to_select)
      rv$selected_concepts <- bundle_concepts()
      DT::selectRows(datatable_proxy, selected = new_rows_to_select)
    })

    observeEvent(input$clear_rows, {
      rv$selected_concepts <- NULL
      DT::selectRows(datatable_proxy, selected = NULL) # nocov
    })

    reactive(rv$selected_concepts)
  })
}

## Use selected dates to calculate number of patients and records per concept
## and join onto selected_data
join_counts_to_concepts <- function(concepts, monthly_counts, selected_dates = NULL) {
  low_freq_threshold <- as.numeric(Sys.getenv("LOW_FREQUENCY_THRESHOLD"))

  if (!is.null(selected_dates)) {
    monthly_counts <- monthly_counts |>
      filter_dates(selected_dates)
  }

  summarised_counts <- monthly_counts |>
    dplyr::group_by(.data$concept_id) |>
    dplyr::summarise(
      total_records = sum(.data$record_count),
      # Note that we can only calculate the average number of persons per month here
      # as we cannot identify unique patients across months
      mean_persons = mean(.data$person_count, na.rm = TRUE),
    )
  # Use inner_join so we only keep concepts for which we have counts in the selected dates
  dplyr::inner_join(concepts, summarised_counts, by = "concept_id") |>
    # Reorder and select the columns we want to display
    dplyr::select(
      "concept_id", "concept_name",
      "total_records", "mean_persons",
      "domain_id", "vocabulary_id", "concept_class_id"
    ) |>
    # Conditionally round numbers for better display
    dplyr::mutate(
      dplyr::across(
        dplyr::where(is.double),
        function(x) ifelse(x > low_freq_threshold, round(x), round(x, 2))
      )
    ) |>
    # Default to displaying by total number of records
    dplyr::arrange(-total_records)
}
