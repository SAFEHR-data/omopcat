test_that("select_bundle reacts to bundle selection", {
  testServer(mod_select_bundle_server, {
    ns <- session$ns
    # Pre-defined golem tests
    expect_true(inherits(ns, "function"))
    expect_true(grepl(id, ns("")))
    expect_true(grepl("test", ns("test")))

    out <- session$getReturned()
    select_bundle <- "smoking"
    session$setInputs(select_bundle = select_bundle)

    expect_true(is.reactive(out))
    expect_type(out(), "integer")
    expect_length(out(), 6)

    expected_concepts <- get_bundle_concepts("smoking", "observation")
    expect_setequal(out(), expected_concepts)
  })
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

test_that("select_bundle server can take 'none' as an option", {
  testServer(mod_select_bundle_server, {
    out <- session$getReturned()
    session$setInputs(select_bundle = "none")

    expect_true(is.reactive(out))
    expect_null(out())
  })
})

# This is quite a trivial test, as it is not possible to check the effects of shiny::update*
# functions with testServer. So this test just does the minimal checking whether the server
# can run without errors.
test_that("update_select_bundle server works", {
  testServer(mod_update_select_bundle_server,
    args = list(selected_bundle_id = reactiveVal()),
    {
      ns <- session$ns
      # Pre-defined golem tests
      expect_true(inherits(ns, "function"))
      expect_true(grepl(id, ns("")))
      expect_true(grepl("test", ns("test")))

      # Set the selected bundle ID and check that it is returned by the select_bundle server
      selected_bundle_id("smoking")
      session$flushReact()

      # The tests below don't actually check anything meaningful
      expect_no_error({
        selection <- mod_select_bundle_server("test")
      })
      expect_true(is.reactive(selection))
    }
  )
})
