test_that("generate_monthly_counts works on a CDM object", {
  monthly_counts <- generate_monthly_counts(mock_cdm, threshold = 0, replacement = 0)
  expect_s3_class(monthly_counts, "data.frame")
  expect_true(nrow(monthly_counts) > 0)
  expect_named(monthly_counts, c(
    "concept_id", "concept_name", "date_year", "date_month", "record_count",
    "person_count", "records_per_person"
  ))
})

test_that("generate_monthly_counts can generate quarterly counts from CDM object", {
  quarterly_counts <- generate_monthly_counts(mock_cdm, threshold = 0, replacement = 0, level = "quarterly")
  expect_s3_class(quarterly_counts, "data.frame")
  expect_true(nrow(quarterly_counts) > 0)
  expect_named(quarterly_counts, c(
    "concept_id", "concept_name", "date_year", "date_quarter", "record_count",
    "person_count", "records_per_person"
  ))

  ## Sanity check date_quarter
  expect_type(quarterly_counts$date_quarter, "integer")
  expect_true(all(quarterly_counts$date_quarter >= 1 & quarterly_counts$date_quarter <= 4))
})

test_that("generate_monthly_counts replaces low-frequency values", {
  threshold <- 5
  replacement <- 0.5
  monthly_counts <- generate_monthly_counts(mock_cdm, threshold = threshold, replacement = replacement)

  cols <- c("record_count", "person_count", "records_per_person")
  expect_true(all(monthly_counts[cols] > 0))
  expect_true(all(monthly_counts[cols] >= threshold | monthly_counts[cols] == replacement))
})

## Set up a mock measurement OMOP table
## Measurements for 3 different patients on the same day, with 1 patient having 2 measurements
generate_mock_measurements <- function(dates, n_persons) {
  grid <- expand.grid(measurement_date = as.Date(dates), person_id = seq_len(n_persons))
  data.frame(
    grid,
    measurement_id = seq_len(nrow(grid)),
    measurement_type_concept_id = 12345,
    measurement_concept_id = 1,
    value_as_number = 0,
    value_as_concept_id = 0
  )
}
mock_measurement <- generate_mock_measurements("2020-01-01", 3)

test_that("summarise_counts produces the expected results at monthly level", {
  res <- summarise_counts(mock_measurement, "measurement_concept_id", "measurement_date", level = "monthly")

  expect_s3_class(res, "data.frame")
  expect_named(res, c("concept_id", "date_year", "date_month", "record_count", "person_count", "records_per_person"))
  expect_equal(nrow(res), 1)

  expect_equal(res$record_count, 3)
  expect_equal(res$person_count, 3)
  expect_equal(res$records_per_person, 1)
})

test_that("summarise_counts produces the expected results at quarterly level", {
  mock_measurement <- generate_mock_measurements(
    dates = c("2012-03-26", "2012-05-04", "2012-09-23", "2012-12-31"),
    n_persons = 3
  )
  res <- summarise_counts(mock_measurement, "measurement_concept_id", "measurement_date", level = "quarterly")

  expect_s3_class(res, "data.frame")
  expect_named(res, c("concept_id", "date_year", "date_quarter", "record_count", "person_count", "records_per_person"))
  expect_equal(nrow(res), 4)

  expect_equal(res$date_quarter, c(1, 2, 3, 4))

  expect_equal(res$person_count, rep(3, 4))
  expect_equal(res$records_per_person, rep(1, 4))
  expect_equal(res$record_count, rep(3, 4))
})

con <- connect_to_db(duckdb::duckdb())
duckdb::duckdb_register(con, "measurement", mock_measurement)
db_measurement <- dplyr::tbl(con, "measurement")
test_that("summarise_counts works on Database-stored tables at monthly level", {
  ref <- summarise_counts(mock_measurement, "measurement_concept_id", "measurement_date", level = "monthly")
  db_res <- summarise_counts(db_measurement, "measurement_concept_id", "measurement_date", level = "monthly")

  expect_s3_class(db_res, "data.frame")
  expect_named(db_res, c("concept_id", "date_year", "date_month", "record_count", "person_count", "records_per_person"))
  expect_type(db_res$record_count, "integer")
  expect_type(db_res$person_count, "integer")
  expect_type(db_res$records_per_person, "double")
  expect_identical(db_res, ref)
})

test_that("summarise_counts works on Database-stored tables at quarterly level", {
  ref <- summarise_counts(mock_measurement, "measurement_concept_id", "measurement_date", level = "quarterly")
  db_res <- summarise_counts(db_measurement, "measurement_concept_id", "measurement_date", level = "quarterly")

  expect_s3_class(db_res, "data.frame")
  expect_named(db_res, c("concept_id", "date_year", "date_quarter", "record_count", "person_count", "records_per_person"))
  expect_type(db_res$record_count, "integer")
  expect_type(db_res$person_count, "integer")
  expect_type(db_res$records_per_person, "double")
  expect_identical(db_res, ref)
})
