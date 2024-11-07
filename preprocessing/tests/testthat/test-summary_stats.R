test_that("generate_summary_stats works on a CDM object", {
  summary_stats <- generate_summary_stats(mock_cdm)
  expect_s3_class(summary_stats, "data.frame")
  expect_named(summary_stats, c(
    "concept_id", "concept_name", "summary_attribute", "value_as_number", "value_as_string"
  ))
})

## Mock measurments for 2 concepts
mock_measurements <- data.frame(
  measurement_id = 1:8,
  person_id = 1,
  measurement_type_concept_id = rep(c(12345, 23456), each = 4),
  measurement_concept_id = rep(c(1, 2), each = 4),
  measurement_date = "2020-01-01",
  value_as_number = c(2, 1, 2, 1, rep(NA, 4)),
  value_as_concept_id = c(rep(0, 4), c(1, 1, 2, 3))
)

test_that("calculate_summary_stats produces the expected results", {
  res <- calculate_summary_stats(mock_measurements, "measurement_concept_id")
  expect_s3_class(res, "data.frame")
  expect_named(res, c("concept_id", "summary_attribute", "value_as_number", "value_as_concept_id"))
  expect_equal(nrow(res), 5)
  mean <- res[res$summary_attribute == "mean", ][["value_as_number"]]
  sd <- res[res$summary_attribute == "sd", ][["value_as_number"]]
  expect_equal(mean, 1.5)
  expect_equal(sd^2, 1 / 3)

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
