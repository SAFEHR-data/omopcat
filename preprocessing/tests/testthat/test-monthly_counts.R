test_that("generate_monthly_counts works on a CDM object", {
  monthly_counts <- generate_monthly_counts(mock_cdm, threshold = 0, replacement = 0)
  expect_s3_class(monthly_counts, "data.frame")
  expect_true(nrow(monthly_counts) > 0)
  expect_named(monthly_counts, c(
    "concept_id", "concept_name", "date_year", "date_month", "record_count",
    "person_count", "records_per_person"
  ))
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
mock_measurement <- data.frame(
  measurement_id = 1:4,
  person_id = c(1, 1, 2, 3),
  measurement_type_concept_id = 12345,
  measurement_concept_id = 1,
  measurement_date = "2020-01-01",
  value_as_number = c(2, 1, 2, 1),
  value_as_concept_id = 0
)

test_that("summarise_counts produces the expected results at monthly level", {
  res <- summarise_counts(mock_measurement, "measurement_concept_id", "measurement_date", level = "monthly")
  expect_s3_class(res, "data.frame")
  expect_named(res, c("concept_id", "date_year", "date_month", "record_count", "person_count", "records_per_person"))
  expect_equal(nrow(res), 1)
  expect_equal(res$person_count, 3)
  expect_equal(res$records_per_person, 4 / 3)
})

con <- duckdb::dbConnect(duckdb::duckdb())
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
  expect_named(db_res, c("concept_id", "date_year", "date_month", "record_count", "person_count", "records_per_person"))
  expect_type(db_res$record_count, "integer")
  expect_type(db_res$person_count, "integer")
  expect_type(db_res$records_per_person, "double")
  expect_identical(db_res, ref)
})
