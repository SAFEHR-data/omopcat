# previous test data commented out temporarily because I want to create a simpler one to test counts
# we could have two separate test datasets

# mock_data <- data.frame(
#   concept_id = c(40213251, 133834, 4057420),
#   concept_name = c(
#     "varicella virus vaccine",
#     "Atopic dermatitis",
#     "Catheter ablation of tissue of heart"
#   ),
#   domain_id = c("Drug", "Condition", "Procedure"),
#   vocabulary_id = c("CVX", "SNOMED", "SNOMED"),
#   concept_class_id = c("CVX", "Clinical Finding", "Procedure"),
#   standard_concept = c("S", "S", "S"),
#   concept_code = c("21", "24079001", "18286008")
# )

# FIXME: use `mock_monthly_counts` from helper

# to test calculation of record and patient counts
#
# start making simpler test data explicitly to test counting
df_concepts <- data.frame(
  concept_id = c(1, 2, 3),
  concept_name = c("2019", "2019-2020", "2019-2021"),
  domain_id = "Drug",
  vocabulary_id = "LOINC",
  concept_class_id = "test",
  standard_concept = "S",
  concept_code = "test"
)

# 10 patients, with 10 records each
# concept 1:2019, concept2:2019-2020, concept3:2019-2021
df_monthly_counts <- data.frame(
  concept_id = c(1, 2, 2, 3, 3, 3),
  date_year = c(2019, 2019, 2020, 2019, 2020, 2021),
  date_month = 1,
  person_count = 10,
  record_count = 100,
  records_per_person = 10
)

selected_dates <- c("2019-01-01", "2022-01-01")
reactive_dates <- reactiveVal(selected_dates)

test_that("Adding records and patients counts to concepts table works", {
  concepts_with_counts <- join_counts_to_concepts(df_concepts, df_monthly_counts, selected_dates)

  expect_in(c("concept_id", "concept_name", "records", "patients"), names(concepts_with_counts))
  expect_equal(nrow(concepts_with_counts), 3)
  expect_equal(concepts_with_counts$records, c(100, 200, 300))
  expect_equal(concepts_with_counts$patients, c(10, 20, 30))
})

test_that("Added counts depends on selected dates", {
  selected_dates <- c("2019-01-01", "2019-12-31")
  concepts_with_counts <- join_counts_to_concepts(df_concepts, df_monthly_counts, selected_dates)

  expect_equal(concepts_with_counts$records, c(100, 100, 100))
  expect_equal(concepts_with_counts$patients, c(10, 10, 10))
})

test_that("datatable server works", {
  testServer(
    mod_datatable_server,
    args = list(
      concepts = reactiveVal(df_concepts),
      monthly_counts = df_monthly_counts,
      selected_dates = reactive_dates
    ),
    {
      ns <- session$ns
      # Pre-defined golem tests
      expect_true(inherits(ns, "function"))
      expect_true(grepl(id, ns("")))
      expect_true(grepl("test", ns("test")))

      out <- session$getReturned()
      expect_true(is.reactive(out))
      expect_s3_class(out(), "data.frame")
      expect_s3_class(output$datatable, "json")
    }
  )
})

test_that("module ui works", {
  ui <- mod_datatable_ui(id = "test")
  golem::expect_shinytaglist(ui)
  # Check that formals have not been removed
  fmls <- formals(mod_datatable_ui)
  for (i in c("id")) {
    expect_true(i %in% names(fmls))
  }
})
