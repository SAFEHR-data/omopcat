test_that("stat_numeric_plot correctly processes data", {
  # GIVEN: a data frame with summary statistics that still needs to be processed before plotting
  # WHEN: stat_numeric_plot is called with this data
  # THEN: the data is first processed correctly and a plot is generated without errors
  mock_stats <- data.frame(
    concept_id = c(40213251, 40213251),
    summary_attribbute = c("mean", "sd"),
    value_as_string = c(NA, NA),
    value_as_number = c(1.5, 0.5)
  )
  expected_data <- data.frame(concept_id = 40213251, mean = 1.5, sd = 0.5)

  p <- stat_numeric_plot(mock_stats)
  expect_identical(p$data, expected_data)
})
