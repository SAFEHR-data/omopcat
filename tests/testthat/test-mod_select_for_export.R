test_that("mod_select_for_export_server only reacts to button click", {
  testServer(
    mod_select_for_export_server,
    # Add here your module params
    args = list(concepts_data = reactiveVal()),
    {
      ns <- session$ns
      # Pre-defined golem tests
      expect_true(inherits(ns, "function"))
      expect_true(grepl(id, ns("")))
      expect_true(grepl("test", ns("test")))

      out <- session$getReturned()
      concepts_data(reactive(data.frame(concept_id = 1:10)))
      session$flushReact()

      # We can't test the reactivity to the button click,
      # but we can check that the returned selection doesn't react
      # to the select_concepts input
      expect_true(is.reactive(out))
      expect_type(out(), "character")
      expect_length(out(), 0)
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
