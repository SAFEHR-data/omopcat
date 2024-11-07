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
