test_that("datatable server works", {
  testServer(
    mod_export_tab_server,
    args = list(id = "test", concepts = reactiveVal(mock_selection_data$concept_id)),
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
  ui <- mod_export_tab_ui(id = "test")
  golem::expect_shinytaglist(ui)
  # Check that formals have not been removed
  fmls <- formals(mod_datatable_ui)
  for (i in c("id")) {
    expect_true(i %in% names(fmls))
  }
})
