mock_concept_ids <- reactiveVal()
mock_date_range <- reactiveVal(c("2019-04-01", "2024-08-01"))

test_that("mod_plots_server reacts to changes in the selected concept", {
  testServer(
    mod_plots_server,
    args = list(selected_concept_ids = mock_concept_ids, selected_dates = mock_date_range),
    {
      ns <- session$ns
      expect_true(inherits(ns, "function"))
      expect_true(grepl(id, ns("")))
      expect_true(grepl("test", ns("test")))

      selected_concept <- 3003573L
      mock_concept_ids(selected_concept) # update reactive value
      session$flushReact()
      expect_identical(unique(filtered_summary_stats()$concept_id), selected_concept)

      selected_concept2 <- 4276526L
      mock_concept_ids(selected_concept2) # update reactive value
      session$flushReact()
      expect_identical(unique(filtered_summary_stats()$concept_id), selected_concept2)
    }
  )
})

test_that("mod_plots_server reacts to changes in the selected date range", {
  testServer(
    mod_plots_server,
    args = list(selected_concept_ids = mock_concept_ids, selected_dates = mock_date_range),
    {
      ns <- session$ns
      expect_true(inherits(ns, "function"))
      expect_true(grepl(id, ns("")))
      expect_true(grepl("test", ns("test")))

      mock_concept_ids(4092281L)

      selected_dates <- c("2019-01-01", "2019-12-31")
      mock_date_range(selected_dates)
      session$flushReact()
      expect_true(all(filtered_monthly_counts()$date_year == 2019))

      ## Case when no data for given range
      selected_dates2 <- c("3019-01-01", "3019-12-31")
      mock_date_range(selected_dates2)
      session$flushReact()
      expect_equal(nrow(filtered_monthly_counts()), 0)
    }
  )
})

test_that("Date filtering works as expected", {
  mock_data <- data.frame(
    date_year = c(2019L, 2020L, 2020L),
    date_month = c(4L, 3L, 5L)
  )

  # Test boundary dates, we only care up to the month level
  selected_dates <- c("2019-04-01", "2020-05-01")
  expect_equal(nrow(filter_dates(mock_data, selected_dates)), 3)

  # This checks a previous bug where a row with date_month larger than the date range months
  # would always get removed while it should be kept in case the year is within the range
  # e.g. 2019-04 should be kept when the range is 2019-01 to 2020-01
  selected_dates2 <- c("2019-01-01", "2020-01-01")
  expect_equal(nrow(filter_dates(mock_data, selected_dates2)), 1)
})

test_that("mod_plots_server fails when input is missing", {
  testServer(
    mod_plots_server,
    args = list(selected_concept_ids = reactiveVal(NULL), selected_dates = mock_date_range),
    {
      # When no concept_id is selected, no output should be generated
      # shiny::req() silently returns an error when the input is missing
      expect_error(output$monthly_counts)
    }
  )
})

test_that("mod_plots_server generates an error when no data is available for the selected concept", {
  testServer(
    mod_plots_server,
    args = list(selected_concept_ids = reactiveVal(NULL), selected_dates = mock_date_range),
    {
      mock_concept_ids(9999999)
      session$flushReact()
      expect_error(output$summary_plot)
    }
  )
})

test_that("module ui works", {
  ui <- mod_plots_ui(id = "test")
  golem::expect_shinytaglist(ui)
  # Check that formals have not been removed
  fmls <- formals(mod_plots_ui)
  for (i in c("id")) {
    expect_true(i %in% names(fmls))
  }
})
