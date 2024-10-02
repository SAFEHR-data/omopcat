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
  expect_error(filter_dates(monthly_counts, selected_dates), "Invalid date range, end date is before start date")
})
