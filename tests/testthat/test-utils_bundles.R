test_that("We can retrieve bundles data", {
  bundles <- get_bundles()
  expect_s3_class(bundles, "data.frame")
  expect_true(nrow(bundles) > 0)
})

test_that("We can retrieve concepts for a given bundle", {
  all_bundles <- get_bundles()
  select_bundle <- all_bundles[1, ]
  concepts <- get_concepts_by_bundle(domain = select_bundle$domain, id = select_bundle$id)
  expect_s3_class(concepts, "data.frame")
})
