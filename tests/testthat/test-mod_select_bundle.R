mock_data <- data.frame(
  id = c("bundle_measurement", "bundle_observation"),
  concept_name = c("Bundle Measurement", "Bundle Observation"),
  domain = c("measurement", "observation"),
  version = c("latest", "latest")
)

test_that("dropdown list server works", {
  testServer(
    mod_select_bundle_server,
    args = list(bundles_table = mock_data),
    {
      ns <- session$ns
      # Pre-defined golem tests
      expect_true(inherits(ns, "function"))
      expect_true(grepl(id, ns("")))
      expect_true(grepl("test", ns("test")))

      out <- session$getReturned()
      expect_true(is.reactive(out))
    }
  )
})

test_that("module ui works", {
  ui <- mod_select_bundle_ui(id = "test")
  golem::expect_shinytaglist(ui)
  # Check that formals have not been removed
  fmls <- formals(mod_select_bundle_ui)
  for (i in c("id")) {
    expect_true(i %in% names(fmls))
  }
})
