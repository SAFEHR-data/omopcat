#' Get input data for the app
#'
#' Utility functions to retrieve the input data for the app from the database.
#'
#' @noRd
get_concepts_table <- function() {
  if (golem::app_dev()) {
    return(data.frame(
      concept_id = c(40213251, 133834, 4057420, 1234567),
      concept_name = c(
        "varicella virus vaccine",
        "Atopic dermatitis",
        "Catheter ablation of tissue of heart",
        "Dummy categorical"
      ),
      domain_id = c("Drug", "Condition", "Procedure", "Observation"),
      vocabulary_id = c("CVX", "SNOMED", "SNOMED", "TEST"),
      concept_class_id = c("CVX", "Clinical Finding", "Procedure", "TEST"),
      standard_concept = c("S", "S", "S", "S"),
      concept_code = c("21", "24079001", "18286008", "000")
    ))
  }

  con <- connect_to_test_db()
  withr::defer(DBI::dbDisconnect(con))
  DBI::dbReadTable(con, "calypso_concepts")
}

get_monthly_counts <- function() {
  if (golem::app_dev()) {
    return(
      data.frame(
        concept_id = c(
          rep(c(40213251, 133834, 4057420), each = 3)
        ),
        date_year = c(2019L, 2020L, 2020L, 2019L, 2020L, 2020L, 2020L, 2019L, 2019L),
        date_month = c(4L, 3L, 5L, 5L, 8L, 4L, 11L, 6L, 3L),
        person_count = c(1, 1, 3, 4, 2, 3, 2, 4, 1),
        records_per_person = c(1, 1, 1, 1, 1, 1, 1, 1, 1)
      )
    )
  }

  con <- connect_to_test_db()
  withr::defer(DBI::dbDisconnect(con))
  DBI::dbReadTable(con, "calypso_monthly_counts")
}

get_summary_stats <- function() {
  if (golem::app_dev()) {
    return(
      data.frame(
        concept_id = c(rep(c(40213251, 133834, 4057420), each = 2), rep(1234567, 3)),
        summary_attribute = c(rep(c("mean", "sd"), times = 3), rep("frequency", 3)),
        value_as_string = c(rep(NA, 6), paste0("cat_", seq(3))),
        value_as_number = c(1.5, 0.5, 2.5, 0.7, 3.5, 0.8, c(42, 23, 68))
      )
    )
  }

  con <- connect_to_test_db()
  withr::defer(DBI::dbDisconnect(con))
  DBI::dbReadTable(con, "calypso_summary_stats")
}
