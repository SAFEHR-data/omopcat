test_that("daterange module returns the selected dates as a reactive", {
  testServer(mod_date_range_server, {
    ns <- session$ns
    expect_true(inherits(ns, "function"))
    expect_true(grepl(id, ns("")))
    expect_true(grepl("test", ns("test")))

    expected_dates <- as.Date(c("2020-01-01", "2020-01-02"))
    session$setInputs(date_range = expected_dates)

    returned_dates <- session$getReturned()

    expect_true(is.reactive(returned_dates))
    expect_s3_class(returned_dates(), "Date")
    expect_identical(returned_dates(), expected_dates)
  })
})

test_that("module ui works", {
  ui <- mod_date_range_ui(id = "test")
  golem::expect_shinytaglist(ui)
  # Check that formals have not been removed
  fmls <- formals(mod_date_range_ui)
  for (i in c("id")) {
    expect_true(i %in% names(fmls))
  }
})
