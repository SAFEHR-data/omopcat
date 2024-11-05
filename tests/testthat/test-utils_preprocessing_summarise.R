## Set up a mock measurement OMOP table
## Measurements for 3 different patients on the same day, with 1 patient having 2 measurements
measurement <- data.frame(
  measurement_id = 1:4,
  person_id = c(1, 1, 2, 3),
  measurement_type_concept_id = 12345,
  measurement_concept_id = 1,
  measurement_date = "2020-01-01",
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
  ref <- calculate_monthly_counts(measurement, measurement_concept_id, measurement_date)
  db_res <- calculate_monthly_counts(db_measurement, measurement_concept_id, measurement_date)

  expect_s3_class(db_res, "data.frame")
  expect_named(db_res, c("concept_id", "date_year", "date_month", "record_count", "person_count", "records_per_person"))
  expect_type(db_res$record_count, "integer")
  expect_type(db_res$person_count, "integer")
  expect_type(db_res$records_per_person, "double")
  expect_identical(db_res, ref)
})

test_that("calculate_summary_stats produces the expected results", {
  res <- calculate_summary_stats(measurement, "measurement_concept_id")
  expect_s3_class(res, "data.frame")
  expect_named(res, c("concept_id", "summary_attribute", "value_as_number", "value_as_concept_id"))
  expect_equal(nrow(res), 2)
  mean <- res[res$summary_attribute == "mean", ][["value_as_number"]]
  sd <- res[res$summary_attribute == "sd", ][["value_as_number"]]
  expect_equal(mean, 1.5)
  expect_equal(sd^2, 1 / 3)
})

## Add a categorical concept
categorical_measurement <- data.frame(
  measurement_id = 1:4,
  person_id = c(1, 1, 2, 3),
  measurement_type_concept_id = 12345,
  measurement_concept_id = 2,
  measurement_date = as.Date("2020-01-01"),
  value_as_number = NA,
  value_as_concept_id = c(1, 1, 2, 3)
)
measurement <- rbind(measurement, categorical_measurement)
test_that("calculate_summary_stats can handle categorical concepts", {
  res <- calculate_summary_stats(measurement, "measurement_concept_id")
  frequencies <- res[res$summary_attribute == "frequency", ]
  expect_equal(nrow(frequencies), 3)
  expect_equal(frequencies$value_as_number, c(2, 1, 1))
  expect_equal(frequencies$value_as_concept_id, c(1, 2, 3))
})

db <- dbplyr::src_memdb()
db_measurement <- dplyr::copy_to(db, measurement, name = "measurement", overwrite = TRUE)
test_that("calculate_summary_stats works with a database-stored table", {
  res <- calculate_summary_stats(db_measurement, "measurement_concept_id")
  expect_s3_class(res, "data.frame")
  expect_named(res, c("concept_id", "summary_attribute", "value_as_number", "value_as_concept_id"))
})
