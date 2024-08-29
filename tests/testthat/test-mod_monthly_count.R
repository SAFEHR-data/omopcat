mock_monthly_counts <- data.frame(
  concept_id = rep(c(40213251, 133834, 4057420), each = 3),
  date_year = c(2019L, 2020L, 2020L, 2019L, 2020L, 2020L, 2020L, 2019L, 2019L),
  date_month = c(4L, 3L, 5L, 5L, 8L, 4L, 11L, 6L, 3L),
  person_count = c(1, 1, 3, 4, 2, 3, 2, 4, 1),
  records_per_person = c(1, 1, 1, 1, 1, 1, 1, 1, 1)
)

# Application-logic tests ---------------------------------------------------------------------

mock_concept_row <- reactiveVal()
mock_date_range <- reactiveVal(c("2019-04-01", "2024-08-01"))

test_that("mod_monthly_count_server reacts to changes in the selected concept", {
  testServer(
    mod_monthly_count_server,
    # Add here your module params
    args = list(data = mock_monthly_counts, selected_concept = mock_concept_row, selected_dates = mock_date_range),
    {
      ns <- session$ns
      expect_true(inherits(ns, "function"))
      expect_true(grepl(id, ns("")))
      expect_true(grepl("test", ns("test")))

      selected_row <- list(concept_id = 40213251, concept_name = "test")
      mock_concept_row(selected_row) # update reactive value
      session$flushReact()
      expect_identical(unique(filtered_monthly_counts()$concept_id), selected_row$concept_id)

      selected_row2 <- list(concept_id = 133834, concept_name = "test")
      mock_concept_row(selected_row2) # update reactive value
      session$flushReact()
      expect_identical(unique(filtered_monthly_counts()$concept_id), selected_row2$concept_id)
    }
  )
})

test_that("mod_monthly_count_server reacts to changes in the selected date range", {
  testServer(
    mod_monthly_count_server,
    # Add here your module params
    args = list(data = mock_monthly_counts, selected_concept = mock_concept_row, selected_dates = mock_date_range),
    {
      ns <- session$ns
      expect_true(inherits(ns, "function"))
      expect_true(grepl(id, ns("")))
      expect_true(grepl("test", ns("test")))

      mock_concept_row(list(concept_id = 40213251, concept_name = "test")) # update reactive value

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
  testServer(
    mod_monthly_count_server,
    args = list(data = mock_monthly_counts, selected_concept = mock_concept_row, selected_dates = mock_date_range),
    {
      # We have data for this concept from 2019-04 to 2020-05
      mock_concept_row(list(concept_id = 40213251, concept_name = "test")) # update reactive value

      # Test boundary dates, we only care up to the month level
      selected_dates <- c("2019-04-01", "2020-05-01")
      mock_date_range(selected_dates)
      session$flushReact()
      expect_equal(nrow(filtered_monthly_counts()), 3)

      # This checks a previous bug where a row with date_month larger than the date range months
      # would always get removed while it should be kept in case the year is within the range
      # e.g. 2019-04 should be kept when the range is 2019-01 to 2020-01
      selected_dates2 <- c("2019-01-01", "2020-01-01")
      mock_date_range(selected_dates2)
      session$flushReact()
      expect_equal(nrow(filtered_monthly_counts()), 1)
    }
  )
})

test_that("mod_monthly_count_server fails when input is missing", {
  testServer(
    mod_monthly_count_server,
    args = list(data = mock_monthly_counts, selected_concept = reactiveVal(NULL), selected_dates = mock_date_range),
    {
      # When no concept_id is selected, no output should be generated
      # shiny::req() silently returns an error when the input is missing
      expect_error(output$monthly_count_plot)

      # Same for mising dates
      mock_date_range(NULL)
      session$flushReact()
      expect_error(output$monthly_count_plot)
    }
  )
})

test_that("mod_monthly_count_server generates an empty plot when no data is available for the selected concept", {
  testServer(
    mod_monthly_count_server,
    args = list(data = mock_monthly_counts, selected_concept = mock_concept_row, selected_dates = mock_date_range),
    {
      mock_concept_row(list(concept_id = 9999999, concept_name = "idontexist"))
      expect_length(output$monthly_count_plot$coordmap$panels[[1]]$mapping, 0)
    }
  )
})

test_that("module ui works", {
  ui <- mod_monthly_count_ui(id = "test")
  golem::expect_shinytaglist(ui)
  # Check that formals have not been removed
  fmls <- formals(mod_monthly_count_ui)
  for (i in c("id")) {
    expect_true(i %in% names(fmls))
  }
})


# Business-logic tests ------------------------------------------------------------------------

test_that("monthly_count_plot correctly parses dates", {
  mock_counts <- mock_monthly_counts[mock_monthly_counts$concept_id == 40213251, ]
  expected_data <- mock_counts
  expected_data$date <- as.Date(paste0(
    expected_data$date_year, "-", expected_data$date_month, "-01"
  ))

  p <- monthly_count_plot(mock_counts, plot_title = "test")
  expect_s3_class(p, "ggplot")
  expect_identical(as.data.frame(p$data), expected_data)
  expect_false(is.null(p$mapping))
  expect_false(is.null(p$layers))
})

test_that("Date range filtering fails for invalid date range", {
  selected_dates <- c("2020-01-01", "2019-01-01")
  expect_error(.filter_dates(monthly_counts, selected_dates), "Invalid date range, end date is before start date")
})
