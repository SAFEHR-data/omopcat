mock_data <- data.frame(x = c(0, 1, 2, 3), y = c(9, 8, 1, 0), z = letters[1:4])

test_that("replace_low_frequencies works", {
  cols <- c("x", "y")
  replacement <- 0.5

  ## Test a range of thresholds
  for (threshold in seq(-10, 10)) {
    out <- replace_low_frequencies(mock_data, cols,
      threshold = threshold, replacement = replacement
    )
    expect_true(all(out[cols] > 0))
    expect_true(all(out[cols] >= threshold | out[cols] == replacement))
  }
})

test_that("replace_low_frequencies fails for invalid threshold or replacement", {
  expect_error(
    replace_low_frequencies(mock_data, c("x", "y"), threshold = "foo", replacement = 0)
  )
  expect_error(
    replace_low_frequencies(mock_data, c("x", "y"), threshold = 0, replacement = "bar")
  )
})
