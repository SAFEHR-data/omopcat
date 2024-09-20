test_that("mod_select_concepts_server reacts to concept selection", {
  testServer(
    mod_select_concepts_server,
    # Add here your module params
    args = list(concepts_table = mock_selection_data),
    {
      ns <- session$ns
      # Pre-defined golem tests
      expect_true(inherits(ns, "function"))
      expect_true(grepl(id, ns("")))
      expect_true(grepl("test", ns("test")))

      out <- session$getReturned()
      select_concepts <- mock_selection_data$concept_name[c(2, 3)]
      session$setInputs(select_concepts = select_concepts)

      expect_s3_class(out(), "data.frame")
      expect_equal(nrow(out()), 2)
      expect_identical(out()$concept_name, select_concepts)
    }
  )
})

test_that("module ui works", {
  ui <- mod_select_concepts_ui(id = "test")
  golem::expect_shinytaglist(ui)
  # Check that formals have not been removed
  fmls <- formals(mod_select_concepts_ui)
  for (i in c("id")) {
    expect_true(i %in% names(fmls))
  }
})
