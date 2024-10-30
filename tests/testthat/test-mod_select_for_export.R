test_that("mod_select_for_export_server only reacts to button click", {
  select_concepts <- get_concepts_table()$concept_name[c(2, 3)]
  testServer(
    mod_select_for_export_server,
    # Add here your module params
    args = list(selected_concepts = reactiveVal(select_concepts)),
    {
      ns <- session$ns
      # Pre-defined golem tests
      expect_true(inherits(ns, "function"))
      expect_true(grepl(id, ns("")))
      expect_true(grepl("test", ns("test")))

      out <- session$getReturned()
      session$setInputs(select_concepts = select_concepts)
      session$flushReact()

      # We can't test the reactivity to the button click,
      # but we can check that the returned selection doesn't react
      # to the select_concepts input
      expect_true(is.reactive(out))
      # The returned value is an empty reactive at this point, so this should error
      expect_error(nrow(out()))
    }
  )
})

test_that("module ui works", {
  ui <- mod_select_for_export_ui(id = "test")
  golem::expect_shinytaglist(ui)
  # Check that formals have not been removed
  fmls <- formals(mod_select_for_export_ui)
  for (i in c("id")) {
    expect_true(i %in% names(fmls))
  }
})
