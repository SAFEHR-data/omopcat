# Disable cli messages
withr::local_options(usethis.quiet = TRUE, cli.default_handler = function(...) {})

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
  expect_false(preprocess(out_path = out_path))
})

test_that("preprocessing fails if envvars are missing", {
  withr::local_envvar(
    ENV = "prod",
    DB_NAME = NULL,
    HOST = NULL,
    PORT = NULL,
    DB_USERNAME = NULL,
    DB_PASSWORD = NULL,
    DB_CDM_SCHEMA = NULL
  )
  expect_error(preprocess(out_path = tempfile()), "not set")

  withr::local_envvar(
    ENV = "test",
    TEST_DB_DIR = NULL,
    TEST_DB_NAME = NULL,
    TEST_DB_OMOP_VERSION = NULL,
    DB_CDM_SCHEMA = NULL
  )
  expect_error(preprocess(out_path = tempfile()), "not set")
})
