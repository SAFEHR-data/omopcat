## Set up a test CDM object with a single OMOP table for testing
person <- data.frame(
  person_id = 1, gender_concept_id = 0, year_of_birth = 1990,
  race_concept_id = 0, ethnicity_concept_id = 0
)
observation_period <- data.frame(
  observation_period_id = 1, person_id = 1,
  observation_period_start_date = as.Date("2000-01-01"),
  observation_period_end_date = as.Date("2025-12-31"),
  period_type_concept_id = 0
)
measurement <- data.frame(
  measurement_id = 1, person_id = 1, measurement_concept_id = 1,
  measurement_type_concept_id = 12345,
  measurement_date = as.Date("2020-01-01"), value_as_number = 1
)

mock_cdm <- CDMConnector::cdm_from_tables(
  tables = list("person" = person, "observation_period" = observation_period, "measurement" = measurement),
  cdm_name = "test"
)

test_that("calculate_monthly_counts produces the expected results", {
  res <- calculate_monthly_counts(mock_cdm$measurement, measurement_concept_id, measurement_date)
  expect_s3_class(res, "data.frame")
  expect_named(res, c("concept_id", "date_year", "date_month", "person_count", "records_per_person"))
  expect_equal(nrow(res), 1)
  expect_equal(res$person_count, 1)
  expect_equal(res$records_per_person, 1)
})
