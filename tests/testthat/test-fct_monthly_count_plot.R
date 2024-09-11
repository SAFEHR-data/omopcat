mock_monthly_counts <- data.frame(
  concept_id = rep(c(40213251, 133834, 4057420), each = 3),
  date_year = c(2019L, 2020L, 2020L, 2019L, 2020L, 2020L, 2020L, 2019L, 2019L),
  date_month = c(4L, 3L, 5L, 5L, 8L, 4L, 11L, 6L, 3L),
  person_count = c(1, 1, 3, 4, 2, 3, 2, 4, 1),
  records_per_person = c(1, 1, 1, 1, 1, 1, 1, 1, 1)
)

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
