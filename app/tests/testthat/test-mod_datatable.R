# Using mock_selection_data and mock_monthly_counts from helper-mock_selection_data.R
# for the concepts table and monthly counts, respectively

selected_dates <- c("2019-01-01", "2022-01-01")
reactive_dates <- reactiveVal(selected_dates)

test_that("datatable server works", {
  testServer(
    mod_datatable_server,
    args = list(
      selected_dates = reactive_dates,
      bundle_concepts = reactiveVal()
    ),
    {
      ns <- session$ns
      # Pre-defined golem tests
      expect_true(inherits(ns, "function"))
      expect_true(grepl(id, ns("")))
      expect_true(grepl("test", ns("test")))

      # NOTE: the return value of mod_datatable_server is a vector of the concepts selected from
      # the datatable by a user. When running in tests, the output has 0 rows because there is no
      # user interaction
      selected_concepts <- session$getReturned()
      expect_true(is.reactive(selected_concepts))
      expect_type(selected_concepts(), "NULL")
      expect_s3_class(output$datatable, "json")

      # Check that concepts table only shows concepts that have records for the selected date range
      # To check this, we access the reactive object `concepts_with_counts` created within the server
      selected_dates(c("2020-01-01", "2020-12-31"))
      session$flushReact()
      expect_equal(nrow(rv$concepts_with_counts), 4)
      expect_true(all(rv$concepts_with_counts$total_records > 0))
    }
  )
})

test_that("Selected rows are updated when updating `bundle_concepts`", {
  testServer(
    mod_datatable_server,
    args = list(
      selected_dates = reactive_dates,
      bundle_concepts = reactiveVal()
    ),
    {
      # Not really possible to test the updating of the selected rows, but we can check
      # whether the reactive row_indices get updated correctly as a proxy
      select_concepts <- rv$concepts_with_counts$concept_id[c(1, 2)]
      bundle_concepts(select_concepts)
      session$flushReact()
      expect_equal(rv$selected_concepts, select_concepts)
    }
  )
})

test_that("module ui works", {
  ui <- mod_datatable_ui(id = "test")
  golem::expect_shinytaglist(ui)
  # Check that formals have not been removed
  fmls <- formals(mod_datatable_ui)
  for (i in c("id")) {
    expect_true(i %in% names(fmls))
  }
})

test_that("Adding records and patients counts to concepts table works", {
  concepts_with_counts <- join_counts_to_concepts(mock_selection_data, mock_monthly_counts, selected_dates)

  expect_in(
    c("concept_id", "concept_name", "total_records", "mean_persons"),
    names(concepts_with_counts)
  )
  expect_equal(nrow(concepts_with_counts), 3)
  expect_setequal(concepts_with_counts$total_records, c(100, 200, 300))
  expect_setequal(concepts_with_counts$mean_persons, c(10, 10, 10))
})

test_that("Added counts depends on selected dates", {
  selected_dates <- c("2019-01-01", "2019-12-31")
  concepts_with_counts <- join_counts_to_concepts(mock_selection_data, mock_monthly_counts, selected_dates)

  expect_setequal(concepts_with_counts$total_records, c(100, 100, 100))
  expect_setequal(concepts_with_counts$mean_persons, c(10, 10, 10))
})

test_that("Only concepts with data for the selected date range are kept", {
  selected_dates <- c("2020-01-01", "2020-12-31")
  concepts_with_counts <- join_counts_to_concepts(mock_selection_data, mock_monthly_counts, selected_dates)

  expect_equal(nrow(concepts_with_counts), 2)
  expect_false(40213251 %in% concepts_with_counts$concept_id)
})
