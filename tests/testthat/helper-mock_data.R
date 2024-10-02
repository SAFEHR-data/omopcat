concept_ids <- as.integer(c(40213251, 133834, 4057420))

mock_selection_data <- data.frame(
  concept_id = concept_ids,
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

# Mock data for monthly counts
# 3 concepts
# First concept has 1 record in 2019-04
# Second concept has 2 records: 2020-03 and 2019-05
# Third concept has 3 records: 2020-08, 2020-11 and 2019-06
# For each date, there are 10 patients and 100 total records
mock_monthly_counts <- data.frame(
  concept_id = rep(concept_ids, c(1, 2, 3)),
  date_year = c(2019L, 2020L, 2019L, 2020L, 2020L, 2019L),
  date_month = c(4L, 3L, 5L, 8L, 11L, 6L),
  # These values will be recycled
  person_count = 10,
  record_count = 100,
  records_per_person = 10
)
