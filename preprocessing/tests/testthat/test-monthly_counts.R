test_that("generate_monthly_counts works on a CDM object", {
  cdm <- .setup_cdm_object()
  monthly_counts <- generate_monthly_counts(cdm)
  expect_s3_class(monthly_counts, "data.frame")
  expect_true(nrow(monthly_counts) > 0)
  expect_named(monthly_counts, c(
    "concept_id", "concept_name", "date_year", "date_month", "record_count",
    "person_count", "records_per_person"
  ))
})

## Set up a mock measurement OMOP table
## Measurements for 3 different patients on the same day, with 1 patient having 2 measurements
measurement <- data.frame(
  measurement_id = 1:4,
  person_id = c(1, 1, 2, 3),
  measurement_type_concept_id = 12345,
  measurement_concept_id = 1,
  measurement_date = as.Date("2020-01-01"),
  value_as_number = c(2, 1, 2, 1),
  value_as_concept_id = 0
)

test_that("calculate_monthly_counts produces the expected results", {
  res <- calculate_monthly_counts(measurement, measurement_concept_id, measurement_date)
  expect_s3_class(res, "data.frame")
  expect_named(res, c("concept_id", "date_year", "date_month", "record_count", "person_count", "records_per_person"))
  expect_equal(nrow(res), 1)
  expect_equal(res$person_count, 3)
  expect_equal(res$records_per_person, 4 / 3)
})

db <- dbplyr::src_memdb()
db_measurement <- dplyr::copy_to(db, measurement, name = "measurement", overwrite = TRUE)
test_that("calculate_monthly_counts works on Database-stored tables", {
  res <- calculate_monthly_counts(db_measurement, measurement_concept_id, measurement_date)
  expect_s3_class(res, "data.frame")
  expect_named(res, c("concept_id", "date_year", "date_month", "record_count", "person_count", "records_per_person"))
})
