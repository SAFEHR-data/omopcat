test_that("We can retrieve bundles data", {
  bundles <- all_bundles()
  expect_s3_class(bundles, "data.frame")
  expect_true(nrow(bundles) > 0)
})

test_that("We can retrieve concepts for a given bundle", {
  all_bundles <- all_bundles()
  select_bundle <- all_bundles[1, ]
  concepts <- get_bundle_concepts(domain = select_bundle$domain, id = select_bundle$id)
  expect_type(concepts, "integer")
  expect_true(length(concepts) > 0)
})
