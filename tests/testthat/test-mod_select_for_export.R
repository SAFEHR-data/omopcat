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

      expect_true(is.reactive(out))
      expect_type(out(), "character")
      expect_length(out(), 0)

      # Update input data, the output should not be updated
      n_selected <- 10
      concepts_data(data.frame(concept_id = seq_len(n_selected)))
      session$flushReact()
      expect_length(out(), 0)

      # Mimic button clicking, the output show now be updated
      session$setInputs(add_to_export = 1)
      session$flushReact()
      expect_length(out(), n_selected)
    }
  )
})

test_that("export selection does not remove previously selected items", {
  # The module is designed to keep the previously selected items in the output
  # even if the corresponding rows are deselected
  testServer(mod_select_for_export_server, args = list(concepts_data = reactiveVal()), {
    out <- session$getReturned()

    # Initial selection followed by first button click
    initial_selection <- data.frame(concept_id = c("foo", "bar", "baz"))
    concepts_data(initial_selection)
    session$setInputs(add_to_export = 1)
    session$flushReact()
    expect_identical(out(), initial_selection$concept_id)

    # Update selection, with new value and removing the old ones
    # Second button click should add the new item to the output without erasing the previous ones
    new_selection <- data.frame(concept_id = "hello")
    concepts_data(new_selection)
    session$setInputs(add_to_export = 2)
    session$flushReact()
    expect_identical(out(), c(initial_selection$concept_id, new_selection$concept_id))
  })
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
