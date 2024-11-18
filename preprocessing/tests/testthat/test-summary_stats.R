test_that("generate_summary_stats works on a CDM object", {
  summary_stats <- generate_summary_stats(mock_cdm, threshold = 0, replacement = 0)
  expect_s3_class(summary_stats, "data.frame")
  expect_named(summary_stats, c(
    "concept_id", "concept_name", "summary_attribute", "value_as_number", "value_as_string"
  ))
})

## Mock measurements for 2 concepts
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
  res <- calculate_summary_stats(mock_measurements, "measurement_concept_id",
    threshold = 0, replacement = 0
  )
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

test_that("calculate_summary_stats replaces low-frequency values", {
  threshold <- 10
  replacement <- 2.5

  res <- calculate_summary_stats(mock_measurements, "measurement_concept_id",
    threshold = threshold, replacement = replacement
  )

  is_categorical <- res$summary_attribute == "frequency"
  expect_true(all(res[is_categorical, "value_as_number"] > 0))
  expect_true(all(
    res[is_categorical, "value_as_number"] >= threshold |
      res[is_categorical, "value_as_number"] == replacement
  ))

  ## Only categorical stats should be replaced
  expect_false(all(
    res[!is_categorical, "value_as_number"] >= threshold |
      res[!is_categorical, "value_as_number"] == replacement
  ))
})

db <- dbplyr::src_memdb()
db_measurement <- dplyr::copy_to(db, mock_measurements, name = "measurement", overwrite = TRUE)
test_that("calculate_summary_stats works with a database-stored table", {
  ref <- calculate_summary_stats(mock_measurements, "measurement_concept_id",
    threshold = 0, replacement = 0
  )
  db_res <- calculate_summary_stats(db_measurement, "measurement_concept_id",
    threshold = 0, replacement = 0
  )

  expect_s3_class(db_res, "data.frame")
  expect_named(db_res, c("concept_id", "summary_attribute", "value_as_number", "value_as_concept_id"))
  expect_identical(db_res, ref)
  expect_type(db_res$value_as_number, "double")
})
