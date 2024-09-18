mock_data <- data.frame(
  concept_id = c(40213251, 133834, 4057420),
  concept_name = c(
    "varicella virus vaccine",
    "Atopic dermatitis",
    "Catheter ablation of tissue of heart"
  ),
  domain_id = c("Drug", "Condition", "Procedure"),
  vocabulary_id = c("CVX", "SNOMED", "SNOMED"),
  concept_class_id = c("CVX", "Clinical Finding", "Procedure"),
  standard_concept = c("S", "S", "S"),
  concept_code = c("21", "24079001", "18286008")
)

test_that("mod_select_concepts_server reacts to concept selection", {
  testServer(
    mod_select_concepts_server,
    # Add here your module params
    args = list(concepts_table = reactiveVal(mock_data)),
    {
      ns <- session$ns
      # Pre-defined golem tests
      expect_true(inherits(ns, "function"))
      expect_true(grepl(id, ns("")))
      expect_true(grepl("test", ns("test")))

      out <- session$getReturned()
      select_concepts <- mock_data$concept_name[c(2, 3)]
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
