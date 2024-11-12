test_that("bundles_summary server works", {
  testServer(
    mod_bundles_summary_server,
    # Add here your module params
    {
      ns <- session$ns
      expect_true(inherits(ns, "function"))
      expect_true(grepl(id, ns("")))
      expect_true(grepl("test", ns("test")))

      expect_s3_class(output$bundles, "json")

      # Check that n_concepts is calculated and added to table
      expect_in("n_concepts", colnames(bundle_data))
    }
  )
})

test_that("bundles_summary server returns bundle ID for selected row", {
  testServer(
    mod_bundles_summary_server,
    {
      # Simulate a user clicking the first row
      session$setInputs(bundles_rows_selected = 1)
      out <- session$getReturned()
      expect_true(is.reactive(out))
      expect_type(out(), "character")
      expect_length(out(), 1)
    }
  )
})

test_that("module ui works", {
  ui <- mod_bundles_summary_ui(id = "test")
  golem::expect_shinytaglist(ui)
  # Check that formals have not been removed
  fmls <- formals(mod_bundles_summary_ui)
  for (i in c("id")) {
    expect_true(i %in% names(fmls))
  }
})
