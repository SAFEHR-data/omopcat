test_that("datatable server works", {
  testServer(
    mod_datatable_server,
    {
      ns <- session$ns
      # Pre-defined golem tests
      expect_true(inherits(ns, "function"))
      expect_true(grepl(id, ns("")))
      expect_true(grepl("test", ns("test")))

      out <- session$getReturned()
      expect_true(is.reactive(out))
      expect_s3_class(out(), "data.frame")
      expect_s3_class(output$datatable, "json")
    }
  )
})

test_that("module ui works", {
  ui <- mod_datatable_ui(id = "test")
  golem::expect_shinytaglist(ui)
  # Check that formals have not been removed
  fmls <- formals(mod_datatable_ui)
  for (i in c("id")) {
    expect_true(i %in% names(fmls))
  }
})
