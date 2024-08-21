mock_stats <- data.frame(
  concept_id = rep(c(40213251, 133834, 4057420), each = 2),
  summary_attribute = rep(c("mean", "sd"), times = 3),
  value_as_string = rep(NA, 6),
  value_as_number = c(1.5, 0.5, 2.5, 0.7, 3.5, 0.8)
)


# Application-logic tests ---------------------------------------------------------------------
mock_concept_row <- reactiveVal()

test_that("mod_stat_numeric_server reacts to changes in the selected concept", {
  testServer(
    mod_stat_numeric_server,
    # Add here your module params
    args = list(data = mock_stats, selected_concept = mock_concept_row),
    {
      ns <- session$ns
      expect_true(inherits(ns, "function"))
      expect_true(grepl(id, ns("")))
      expect_true(grepl("test", ns("test")))

      selected_row <- list(concept_id = 40213251, concept_name = "test")
      mock_concept_row(selected_row) # update reactive value
      session$flushReact()
      expect_identical(unique(filtered_summary_stats()$concept_id), selected_row$concept_id)
      expect_equal(nrow(filtered_summary_stats()), 2)

      selected_row2 <- list(concept_id = 40213251, concept_name = "test")
      mock_concept_row(selected_row2) # update reactive value
      session$flushReact()
      expect_identical(unique(filtered_summary_stats()$concept_id), selected_row2$concept_id)
      expect_equal(nrow(filtered_summary_stats()), 2)
    }
  )
})

test_that("mod_stat_numeric_server generates an empty plot when no row is selected", {
  testServer(
    mod_stat_numeric_server,
    args = list(data = mock_stats, selected_concept = reactiveVal(NULL)),
    {
      # When no concept_id is selected, no plot should be rendered
      expect_length(output$stat_numeric_plot$coordmap$panels[[1]]$mapping, 0)
    }
  )
})

test_that("module ui works", {
  ui <- mod_stat_numeric_ui(id = "test")
  golem::expect_shinytaglist(ui)
  # Check that formals have not been removed
  fmls <- formals(mod_stat_numeric_ui)
  for (i in c("id")) {
    expect_true(i %in% names(fmls))
  }
})


# Business-logic tests ------------------------------------------------------------------------

test_that("stat_numeric_plot correctly processes data", {
  # GIVEN: a data frame with summary statistics that still needs to be processed before plotting
  # WHEN: stat_numeric_plot is called with this data
  # THEN: the data is first processed correctly and a plot is generated without errors
  mock_stats <- mock_stats[mock_stats$concept_id == 40213251, ]
  expected_data <- data.frame(concept_id = 40213251, mean = 1.5, sd = 0.5)

  p <- stat_numeric_plot(mock_stats, plot_title = "test")
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

  expect_error(stat_numeric_plot(mock_stats, plot_title = "test"), "Expecting a single concept ID")
})
