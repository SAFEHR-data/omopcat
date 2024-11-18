# Sanity checks
test_that("Dev data files exist", {
  expect_true(file.exists(app_sys("dev_data", "omopcat_concepts.csv")))
  expect_true(file.exists(app_sys("dev_data", "omopcat_monthly_counts.csv")))
  expect_true(file.exists(app_sys("dev_data", "omopcat_summary_stats.csv")))
})

# These tests act as proxy tests for the pre-processing scripts that generate the test data
# making sure the test data files are generated correctly and consistently
test_that("Dev data files are consistent", {
  # To use expect_snapshot_file(), need to save the output to a temporary file
  save_csv <- function(x) {
    path <- tempfile(fileext = ".csv")
    readr::write_csv(x, file = path)
    path
  }
  expect_snapshot_file(save_csv(get_concepts_table()), "concepts_table.csv")
  expect_snapshot_file(save_csv(get_monthly_counts()), "monthly_counts.csv")
  expect_snapshot_file(save_csv(get_summary_stats()), "summary_stats.csv")
})

test_that("Data getters fail in production if envvar not set", {
  withr::local_envvar(GOLEM_CONFIG_ACTIVE = "production", OMOPCAT_DATA_PATH = NA)
  withr::local_options(list("golem.app.prod" = TRUE))

  expect_true(golem::app_prod())
  expect_error(get_concepts_table(), "Environment variable `OMOPCAT_DATA_PATH` not set")
  expect_error(get_monthly_counts(), "Environment variable `OMOPCAT_DATA_PATH` not set")
  expect_error(get_summary_stats(), "Environment variable `OMOPCAT_DATA_PATH` not set")
})

test_that("Data getters fail in production if data directory does not exist", {
  withr::local_envvar(c(
    "GOLEM_CONFIG_ACTIVE" = "production",
    "OMOPCAT_DATA_PATH" = "/i/dont/exist"
  ))
  withr::local_options(list("golem.app.prod" = TRUE))

  expect_true(golem::app_prod())
  expect_error(.read_parquet_table("concepts"), "Data directory '/i/dont/exist' not found")
})

test_that("concept_id is always read in as integer", {
  expect_type(get_concepts_table()$concept_id, "integer")
  expect_type(get_monthly_counts()$concept_id, "integer")
  expect_type(get_summary_stats()$concept_id, "integer")
})
