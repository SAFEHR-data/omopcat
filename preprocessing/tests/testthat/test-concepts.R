test_that("generate_concepts works on a CDM object", {
  concepts <- generate_concepts(mock_cdm, concept_ids = c(1118088, 1569708, 3020630))
  expect_s3_class(concepts, "data.frame")
  expect_equal(nrow(concepts), 3)
  expect_true(
    all(c("concept_id", "concept_name", "vocabulary_id", "domain_id", "concept_class_id") %in% names(concepts))
  )
  expect_type(concepts$concept_id, "integer")
  expect_type(concepts$concept_name, "character")
})
