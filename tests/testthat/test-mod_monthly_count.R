mock_monthly_counts <- data.frame(
  concept_id = rep(c(40213251, 133834, 4057420), each = 3),
  date_year = c(2019L, 2020L, 2020L, 2019L, 2020L, 2020L, 2020L, 2019L, 2019L),
  date_month = c(4L, 3L, 5L, 5L, 8L, 4L, 11L, 6L, 3L),
  person_count = c(1, 1, 3, 4, 2, 3, 2, 4, 1),
  records_per_person = c(1, 1, 1, 1, 1, 1, 1, 1, 1)
)

# Application-logic tests ---------------------------------------------------------------------
mock_concept_row <- reactiveVal()

test_that("mod_monthly_count_server reacts to changes in the selected concept", {
  testServer(
    mod_monthly_count_server,
    # Add here your module params
    args = list(data = mock_monthly_counts, selected_concept = mock_concept_row),
    {
      ns <- session$ns
      expect_true(inherits(ns, "function"))
      expect_true(grepl(id, ns("")))
      expect_true(grepl("test", ns("test")))

      selected_row <- list(concept_id = 40213251, concept_name = "test")
      mock_concept_row(selected_row) # update reactive value
      session$flushReact()
      expect_identical(unique(filtered_monthly_counts()$concept_id), selected_row$concept_id)

      selected_row2 <- list(concept_id = 133834, concept_name = "test")
      mock_concept_row(selected_row2) # update reactive value
      session$flushReact()
      expect_identical(unique(filtered_monthly_counts()$concept_id), selected_row2$concept_id)
    }
  )
})

test_that("mod_monthly_count_server generates an empty plot when no row is selected", {
  testServer(
    mod_monthly_count_server,
    args = list(data = mock_monthly_counts, selected_concept = reactiveVal(NULL)),
    {
      # When no concept_id is selected, no plot should be rendered
      expect_length(output$monthly_count_plot$coordmap$panels[[1]]$mapping, 0)
    }
  )
})

test_that("module ui works", {
  ui <- mod_monthly_count_ui(id = "test")
  golem::expect_shinytaglist(ui)
  # Check that formals have not been removed
  fmls <- formals(mod_monthly_count_ui)
  for (i in c("id")) {
    expect_true(i %in% names(fmls))
  }
})
