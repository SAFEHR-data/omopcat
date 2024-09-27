# Using mock_selection_data and mock_monthly_counts from helper-mock_selection_data.R
# for the concepts table and monthly counts, respectively

selected_dates <- c("2019-01-01", "2022-01-01")
reactive_dates <- reactiveVal(selected_dates)

test_that("datatable server works", {
  testServer(
    mod_datatable_server,
    args = list(
      concepts = reactiveVal(mock_selection_data),
      monthly_counts = mock_monthly_counts,
      selected_dates = reactive_dates
    ),
    {
      ns <- session$ns
      # Pre-defined golem tests
      expect_true(inherits(ns, "function"))
      expect_true(grepl(id, ns("")))
      expect_true(grepl("test", ns("test")))

      # NOTE: the return value of mod_datatable_server is the row selected from the datatable
      # by a user. When running in tests, the output has 0 rows because there is no user interaction
      selected_row <- session$getReturned()
      expect_true(is.reactive(selected_row))
      expect_s3_class(selected_row(), "data.frame")
      expect_s3_class(output$datatable, "json")

      # Check that concepts table only shows concepts that have records for the selected date range
      # To check this, we access the reactive object `concepts_with_counts` created within the server
      selected_dates(c("2020-01-01", "2020-12-31"))
      session$flushReact()
      expect_equal(nrow(concepts_with_counts()), 2)
      expect_false(40213251 %in% concepts_with_counts()$concept_id)
    }
  )
})

test_that("Low frequencies are replaced in the concepts table", {
  testServer(
    mod_datatable_server,
    args = list(
      # Use the dev data to test low frequency replacement
      concepts = reactiveVal(get_concepts_table()),
      monthly_counts = get_monthly_counts(),
      selected_dates = reactive_dates
    ),
    {
      replacement <- as.double(Sys.getenv("LOW_FREQUENCY_REPLACEMENT"))

      expect_true(all(concepts_with_counts()$records >= replacement))
      expect_true(all(concepts_with_counts()$patients >= replacement))
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

  expect_in(c("concept_id", "concept_name", "records", "patients"), names(concepts_with_counts))
  expect_equal(nrow(concepts_with_counts), 3)
  expect_equal(concepts_with_counts$records, c(100, 200, 300))
  expect_equal(concepts_with_counts$patients, c(10, 20, 30))
})

test_that("Added counts depends on selected dates", {
  selected_dates <- c("2019-01-01", "2019-12-31")
  concepts_with_counts <- join_counts_to_concepts(mock_selection_data, mock_monthly_counts, selected_dates)

  expect_equal(concepts_with_counts$records, c(100, 100, 100))
  expect_equal(concepts_with_counts$patients, c(10, 10, 10))
})

test_that("Only concepts with data for the selected date range are kept", {
  selected_dates <- c("2020-01-01", "2020-12-31")
  concepts_with_counts <- join_counts_to_concepts(mock_selection_data, mock_monthly_counts, selected_dates)

  expect_equal(nrow(concepts_with_counts), 2)
  expect_false(40213251 %in% concepts_with_counts$concept_id)
})
