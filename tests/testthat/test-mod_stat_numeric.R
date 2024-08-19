testServer(
  mod_stat_numeric_server,
  # Add here your module params
  args = list(),
  {
    ns <- session$ns
    expect_true(inherits(ns, "function"))
    expect_true(grepl(id, ns("")))
    expect_true(grepl("test", ns("test")))
    # Here are some examples of tests you can
    # run on your module
    # - Testing the setting of inputs
    # session$setInputs(x = 1)
    # expect_true(input$x == 1)
    # - If ever your input updates a reactiveValues
    # - Note that this reactiveValues must be passed
    # - to the testServer function via args = list()
    # expect_true(r$x == 1)
    # - Testing output
    # expect_true(inherits(output$tbl$html, "html"))
  }
)

test_that("module ui works", {
  ui <- mod_stat_numeric_ui(id = "test")
  golem::expect_shinytaglist(ui)
  # Check that formals have not been removed
  fmls <- formals(mod_stat_numeric_ui)
  for (i in c("id")) {
    expect_true(i %in% names(fmls))
  }
})

test_that("stat_numeric_plot correctly processes data", {
  # GIVEN: a data frame with summary statistics that still needs to be processed before plotting
  # WHEN: stat_numeric_plot is called with this data
  # THEN: the data is first processed correctly and a plot is generated without errors
  mock_stats <- data.frame(
    concept_id = c(40213251, 40213251),
    summary_attribute = c("mean", "sd"),
    value_as_string = c(NA, NA),
    value_as_number = c(1.5, 0.5)
  )
  expected_data <- data.frame(concept_id = 40213251, mean = 1.5, sd = 0.5)

  p <- stat_numeric_plot(mock_stats)
  expect_identical(as.data.frame(p$data), expected_data)
})

test_that("stat_numeric_plot only works for a single concept", {
  # GIVEN: a data frame with summary statistics for multiple concepts
  # WHEN: stat_numeric_plot is called with this data
  # THEN: an error is thrown because the function only works for a single concept
  mock_stats <- data.frame(
    concept_id = rep(c(40213251, 40213252), each = 2),
    summary_attribute = c("mean", "sd", "mean", "sd"),
    value_as_string = c(NA, NA, NA, NA),
    value_as_number = c(1.5, 0.5, 2.5, 0.7)
  )

  expect_error(stat_numeric_plot(mock_stats), "Expecting a single concept ID")
})
