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

# to test calculation of record and patient counts
#
# start making simpler test data explicitly to test counting
df_concepts <- data.frame(
  concept_id = c(1, 2, 3),
  concept_name = c("2019", "2019-2020", "2019-2021"),
  domain_id = "Drug",
  vocabulary_id = "LOINC",
  concept_class_id = NA,
  standard_concept = "S",
  concept_code = NA
)

# 10 patients, with 10 records each
# concept 1:2019, concept2:2019-2020, concept3:2019-2021
df_monthly_counts <- data.frame(
  concept_id = c(1, 2, 2, 3, 3, 3),
  date_year = c(2019, 2019,2020, 2019,2020,2021),
  date_month = 1,
  person_count = 10,
  record_count = 100,
  records_per_person = 10
)

date_range_test <- c("2019-01-01", "2022-01-01")


test_that("count of records and patients works", {
  testServer(
    mod_datatable_server,
    args = list(
      concepts = reactiveVal(df_concepts),
      monthly_counts = df_monthly_counts,
      selected_dates = reactiveVal(date_range_test)
    ),
    {
      out <- session$getReturned()

      #these pass doing same thing, not v useful tests
      expect_true(ncol(out()) == 9)
      expect_equal(ncol(out()), 9)

      expect_equal(names(out())[1], "concept_id")
      expect_equal(names(out())[2], "records")
      expect_equal(names(out())[3], "patients")

      #fails actual:0 ???
      expect_equal(nrow(out()), 3)

      #actual NA, expected 100 ???
      expect_equal(out()$records[1], 100)
      #fails, seemingly nothing for records
      expect_equal(out()$records, c(100, 200, 300))

      #expect_equal(out()[["records"]], c(100, 200, 300))
      #selected_dates <- reactiveVal(c("2019-01-01", "2019-12-31"))
      #session$flushReact()
    }
  )
})

test_that("datatable server works", {
  testServer(
    mod_datatable_server,
    args = list(
      concepts = reactiveVal(df_concepts),
      monthly_counts = df_monthly_counts,
      selected_dates = reactiveVal(date_range_test)
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
