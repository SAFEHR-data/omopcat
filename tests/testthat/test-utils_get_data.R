# Sanity checks
test_that("Test data files exist", {
  expect_true(file.exists(app_sys("test_data", "calypso_concepts.csv")))
  expect_true(file.exists(app_sys("test_data", "calypso_monthly_counts.csv")))
  expect_true(file.exists(app_sys("test_data", "calypso_summary_stats.csv")))
})

# These tests act as proxy tests for the pre-processing scripts that generate the test data
# making sure the test data files are generated correctly and consistently
test_that("Test data files are consistent", {
  # To use expect_snapshot_file(), need to save the output to a temporary file
  save_csv <- function(x) {
    path <- tempfile(fileext = ".csv")
    write.csv(x, file = path)
    path
  }
  expect_snapshot_file(save_csv(get_concepts_table()), "concepts_table.csv")
  expect_snapshot_file(save_csv(get_monthly_counts()), "monthly_counts.csv")
  expect_snapshot_file(save_csv(get_summary_stats()), "summary_stats.csv")
})
