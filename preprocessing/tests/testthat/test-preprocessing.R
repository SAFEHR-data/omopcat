# Disable cli messages
withr::local_options(usethis.quiet = TRUE, cli.default_handler = function(...) {})
withr::local_envvar(SUMMARISE_LEVEL = "monthly")

test_that("preprocessing produces the expected files", {
  testthat::skip_on_ci() # avoid re-downloading example database on GHA runners
  out_path <- tempdir()
  expected_files <- c(
    file.path(out_path, "omopcat_concepts.parquet"),
    file.path(out_path, "omopcat_monthly_counts.parquet"),
    file.path(out_path, "omopcat_summary_stats.parquet")
  )
  withr::defer(fs::file_delete(expected_files))

  expect_no_error({
    success <- preprocess(out_path = out_path)
  })
  expect_true(success)
  expect_true(all(file.exists(expected_files)))
})

test_that("preprocessing works with quarterly summarisation", {
  testthat::skip_on_ci() # avoid re-downloading example database on GHA runners
  withr::local_envvar(SUMMARISE_LEVEL = "quarterly")
  out_path <- tempdir()
  expected_files <- c(
    file.path(out_path, "omopcat_concepts.parquet"),
    file.path(out_path, "omopcat_monthly_counts.parquet"),
    file.path(out_path, "omopcat_summary_stats.parquet")
  )
  withr::defer(fs::file_delete(expected_files))

  expect_no_error({
    success <- preprocess(out_path = out_path)
  })
  expect_true(success)
  expect_true(all(file.exists(expected_files)))
})

test_that("preprocessing fails without valid out_path", {
  expect_error(preprocess(out_path = ""), "should not be empty")
})

test_that("preprocessing is skipped if files already exist", {
  out_path <- tempdir()
  out_files <- c(
    file.path(out_path, "omopcat_concepts.parquet"),
    file.path(out_path, "omopcat_monthly_counts.parquet"),
    file.path(out_path, "omopcat_summary_stats.parquet")
  )
  fs::file_create(out_files)
  withr::defer(fs::file_delete(out_files))

  expect_false(preprocess(out_path = out_path))
})

test_that("preprocessing fails in prod if envvars are missing", {
  withr::local_envvar(ENV = "prod")
  required_envvars <- c(
    "DB_NAME",
    "HOST",
    "PORT",
    "DB_USERNAME",
    "DB_PASSWORD",
    "LOW_FREQUENCY_THRESHOLD",
    "LOW_FREQUENCY_REPLACEMENT",
    "SUMMARISE_LEVEL"
  )

  for (envvar in required_envvars) {
    withr::local_envvar(.new = setNames(list(NULL), envvar))
    expect_error(preprocess(out_path = tempfile()), "not set")
  }
})

test_that("Setting up CDM object works for non-prod data", {
  skip_if_not_installed("duckdb")
  withr::local_envvar(ENV = "test")
  cdm <- .setup_cdm_object()
  expect_equal(CDMConnector::cdmVersion(cdm), "5.3")
})
