## Set up a mock measurement OMOP table
## Measurements for 3 different patients on the same day, with 1 patient having 2 measurements
measurement <- data.frame(
  measurement_id = 1:4,
  person_id = c(1, 1, 2, 3),
  measurement_type_concept_id = 12345,
  measurement_concept_id = 1,
  measurement_date = as.Date("2020-01-01"),
  value_as_number = 1
)

test_that("calculate_monthly_counts produces the expected results", {
  res <- calculate_monthly_counts(measurement, measurement_concept_id, measurement_date)
  expect_s3_class(res, "data.frame")
  expect_named(res, c("concept_id", "date_year", "date_month", "person_count", "records_per_person"))
  expect_equal(nrow(res), 1)
  expect_equal(res$person_count, 3)
  expect_equal(res$records_per_person, 4/3)
})
})
