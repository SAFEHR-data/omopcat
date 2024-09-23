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

test_that("datatable server works", {
  testServer(
    mod_datatable_server,
    args = list(data = reactiveVal(mock_data)),
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

#to test calculation of record and patient counts
#
#start making simpler test data explicitly to test counting
df_month_counts <- data.frame(
  concept_id = rep(c(1,2,3), each = 3),
  date_year = rep(c(2019,2020,2021), times = 3),
  date_month = 1,
  person_count = rep(c(10,20,30), each = 3),
  records_per_person = 1
)

df_concepts <- data.frame(
  concept_id = c(1,2,3),
  concept_name = c(
    "2019",
    "2019-2020",
    "2019-2021"
  ),
  domain_id = "Drug",
  vocabulary_id = "LOINC",
  concept_class_id = NA,
  standard_concept = "S",
  concept_code = NA
)


# mock_monthly_counts <- data.frame(
#   concept_id = rep(c(1,2), each = 3),
#   date_year = c(2019, 2020, 2021, 2019L, 2020L, 2020L, 2020L, 2019L, 2019L),
#   date_month = 1,
#   person_count = c(1, 1, 3, 4, 2, 3, 2, 4, 1),
#   records_per_person = c(1, 1, 1, 1, 1, 1, 1, 1, 1)
# )
