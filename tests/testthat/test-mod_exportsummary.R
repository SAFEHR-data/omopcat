source("mock_selection_data.R")

test_that("export summary server works", {
  testServer(
    mod_exportsummary_server,
    args = list(data = reactiveVal(mock_selection_data)),
    {
      ns <- session$ns
      # Pre-defined golem tests
      expect_true(inherits(ns, "function"))
      expect_true(grepl(id, ns("")))
      expect_true(grepl("test", ns("test")))
    }
  )
})

test_that("module ui works", {
  ui <- mod_exportsummary_ui(namespace = "test")
  golem::expect_shinytaglist(ui)
  # Check that formals have not been removed
  fmls <- formals(mod_datatable_ui)
  for (i in c("id")) {
    expect_true(i %in% names(fmls))
  }
})
