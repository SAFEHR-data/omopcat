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

#to test calculation of record and patient counts
#
#start making simpler test data explicitly to test counting
df_concepts <- data.frame(
  concept_id = c(1,2,3),
  concept_name = c("2019","2019-2020","2019-2021"),
  domain_id = "Drug",
  vocabulary_id = "LOINC",
  concept_class_id = NA,
  standard_concept = "S",
  concept_code = NA
)

#I can't yet pass this to the test see comments below
df_month_counts <- data.frame(
  concept_id = rep(c(1,2,3), each = 3),
  date_year = rep(c(2019,2020,2021), times = 3),
  date_month = 1,
  person_count = rep(c(10,20,30), each = 3),
  records_per_person = 1
)

date_range_test <- reactiveVal(c("2019-04-01", "2024-08-01"))

#I want to test that counts work
#BUT currently monthly counts are accessed by a hardcoded csv
#got by get_monthly_counts() within mod_datatable_server()
#I suggest get_monthly_counts() should be moved to app_server.R & the result passed
#so that I can pass test data to mod_datatable_server()
test_that("count of records and patients works", {
  testServer(
    mod_datatable_server,
    args = list(data = reactiveVal(df_concepts),
                selected_dates = date_range_test),
    {

      out <- session$getReturned()

      #this shows that I can access the returned table
      #but only passes the test because there are 9 columns in the hardcoded dev csv from get_monthly_counts()
      expect_true(ncol(out())==9)

    }
  )
})

test_that("datatable server works", {
  testServer(
    mod_datatable_server,
    #args = list(data = reactiveVal(mock_data)),
    args = list(data = reactiveVal(df_concepts),
                selected_dates = date_range_test),
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



