# Sanity checks
test_that("Dev data files exist", {
  expect_true(file.exists(app_sys("dev_data", "calypso_concepts.csv")))
  expect_true(file.exists(app_sys("dev_data", "calypso_monthly_counts.csv")))
  expect_true(file.exists(app_sys("dev_data", "calypso_summary_stats.csv")))
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


## Check if we can access the data used in production
test_that("Test data parquet files exist and are accessible", {
  withr::local_envvar(c(
    "GOLEM_CONFIG_ACTIVE" = "production",
    "CALYPSO_DATA_PATH" = here::here("data/test_data")
  ))
  withr::local_options(list("golem.app.prod" = TRUE))

  data_dir <- Sys.getenv("CALYPSO_DATA_PATH")
  expect_true(dir.exists(data_dir))
  expect_true(golem::app_prod())

  concepts <- get_concepts_table()
  monthly_counts <- get_monthly_counts()
  summary_stats <- get_summary_stats()

  expect_s3_class(concepts, "data.frame")
  expect_s3_class(monthly_counts, "data.frame")
  expect_s3_class(summary_stats, "data.frame")

  expect_named(
    concepts,
    c(
      "concept_id", "concept_name", "vocabulary_id", "domain_id",
      "concept_class_id", "standard_concept", "concept_code"
    )
  )
  expect_named(
    monthly_counts,
    c("concept_id", "concept_name", "date_year", "date_month", "person_count", "records_per_person")
  )
  expect_named(
    summary_stats,
    c("concept_id", "concept_name", "summary_attribute", "value_as_number", "value_as_string")
  )
})
