mock_stats <- data.frame(
  concept_id = rep(c(40213251, 133834, 4057420), each = 2),
  summary_attribute = rep(c("mean", "sd"), times = 3),
  value_as_string = rep(NA, 6),
  value_as_number = c(1.5, 0.5, 2.5, 0.7, 3.5, 0.8)
)

test_that("summary_stat_plot correctly processes data", {
  # GIVEN: a data frame with summary statistics that still needs to be processed before plotting
  # WHEN: summary_stat_plot is called with this data
  # THEN: the data is first processed correctly and a plot is generated without errors
  mock_stats <- mock_stats[mock_stats$concept_id == 40213251, ]
  expected_data <- data.frame(concept_id = 40213251, mean = 1.5, sd = 0.5)

  p <- summary_stat_plot(mock_stats, plot_title = "test")
  expect_identical(as.data.frame(p$data), expected_data)
  expect_s3_class(p, "ggplot")
  expect_true(inherits(p$layers[[1]]$geom, "GeomBoxplot"))
})

test_that("summary_stat_plot only works for a single concept", {
  # GIVEN: a data frame with summary statistics for multiple concepts
  # WHEN: summary_stat_plot is called with this data
  # THEN: an error is thrown because the function only works for a single concept
  mock_stats <- data.frame(
    concept_id = rep(c(40213251, 40213252), each = 2),
    summary_attribute = c("mean", "sd", "mean", "sd"),
    value_as_string = c(NA, NA, NA, NA),
    value_as_number = c(1.5, 0.5, 2.5, 0.7)
  )

  expect_error(summary_stat_plot(mock_stats, plot_title = "test"), "Expecting a single concept ID")
})

test_that("summary_stat_plot works for categorical concepts", {
  # GIVEN: a data frame with summary statistics for a categorical concept
  # WHEN: summary_stat_plot is called with this data
  # THEN: the data is processed correctly and a plot is generated without errors
  mock_stats <- data.frame(
    concept_id = rep(1234567, 3),
    summary_attribute = rep("frequency", 3),
    value_as_string = paste0("cat_", seq(3)),
    value_as_number = c(42, 23, 68)
  )
  expected_plot_data <- mock_stats
  expected_plot_data$value_as_string <- factor(expected_plot_data$value_as_string,
    levels = c("cat_3", "cat_1", "cat_2")
  )

  p <- summary_stat_plot(mock_stats, plot_title = "test")
  expect_identical(as.data.frame(p$data), expected_plot_data)
  expect_s3_class(p, "ggplot")
  expect_true(inherits(p$layers[[1]]$geom, "GeomBar"))
})
