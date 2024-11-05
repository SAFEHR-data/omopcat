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

