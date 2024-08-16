#' Get input data for the app
#'
#' Utility functions to retrieve the input data for the app from the database.
#'
#' @noRd
get_concepts_table <- function() {
  if (golem::app_dev()) {
    return(data.frame(
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
        concept_id = rep(c(40213251, 133834, 4057420), each = 2),
        summary_attribbute = rep(c("mean", "sd"), times = 3),
        value_as_string = rep(NA, 6),
        value_as_number = c(1.5, 0.5, 2.5, 0.7, 3.5, 0.8)
      )
    )
  }

  con <- connect_to_test_db()
  withr::defer(DBI::dbDisconnect(con))
  DBI::dbReadTable(con, "calypso_summary_stats")
}
