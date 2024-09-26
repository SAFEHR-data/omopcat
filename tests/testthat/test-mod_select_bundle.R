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
    expect_s3_class(out(), "data.frame")
    expect_in(c("concept_id", "concept_name"), names(out()))

    expected_concepts <- get_bundle_concepts("smoking", "observation")
    expect_in(out()$concept_id, expected_concepts)
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

test_that("select_bundle server can return all concepts", {
  testServer(mod_select_bundle_server, {
    out <- session$getReturned()
    session$setInputs(select_bundle = "all")

    expect_true(is.reactive(out))
    expect_s3_class(out(), "data.frame")
    expect_in(c("concept_id", "concept_name"), names(out()))
    expect_equal(out()$concept_id, get_concepts_table()$concept_id)
  })
})
