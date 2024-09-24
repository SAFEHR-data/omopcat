cli::cli_h1("Generating summarys statistics")


# Setup ---------------------------------------------------------------------------------------

suppressPackageStartupMessages({
  library(tidyverse)
  library(omopcat)
})

dir <- Sys.getenv("EUNOMIA_DATA_FOLDER")
name <- Sys.getenv("TEST_DB_NAME")
version <- Sys.getenv("TEST_DB_OMOP_VERSION")

db_path <- glue::glue("{dir}/{name}_{version}_1.0.duckdb")
con <- connect_to_db(db_path)

fs::dir_create(
  out_path <- here::here("data/test_data")
)

# Functions -----------------------------------------------------------------------------------

# Function to execute one or more SQL queries and clear results
create_results_tables <- function(con, sql) {
  # Execute sql query
  result <- DBI::dbSendStatement(con, sql)
  # Clear results
  DBI::dbClearResult(result)
}


# Function to produce the 'omopcat_concepts' table
# from a list of concept ids
get_concepts_table <- function(cdm, concepts) {
  # Extract columns from concept table
  cdm$concept |>
    filter(concept_id %in% concepts) |>
    select(
      concept_id,
      concept_name,
      vocabulary_id,
      domain_id,
      concept_class_id,
      standard_concept,
      concept_code
    ) |>
    collect()
}

# Function to produce the 'omopcat_monthly_counts' table
process_monthly_counts <- function(cdm) {
  # Combine results for all tables
  out <- bind_rows(
    cdm$condition_occurrence |> calculate_monthly_counts(condition_concept_id, condition_start_date),
    cdm$drug_exposure |> calculate_monthly_counts(drug_concept_id, drug_exposure_start_date),
    cdm$procedure_occurrence |> calculate_monthly_counts(procedure_concept_id, procedure_date),
    cdm$device_exposure |> calculate_monthly_counts(device_concept_id, device_exposure_start_date),
    cdm$measurement |> calculate_monthly_counts(measurement_concept_id, measurement_date),
    cdm$observation |> calculate_monthly_counts(observation_concept_id, observation_date),
    cdm$specimen |> calculate_monthly_counts(specimen_concept_id, specimen_date)
  )

  # Map concept names to the concept IDs
  concept_names <- select(cdm$concept, concept_id, concept_name) |>
    filter(concept_id %in% out$concept_id) |>
    collect()
  out |>
    left_join(concept_names, by = c("concept_id" = "concept_id")) |>
    select(concept_id, concept_name, everything())
}

# Function to produce the 'omopcat_summary_stats' table
process_summary_stats <- function(cdm) {
  table_names <- c("measurement", "observation")
  concept_names <- c("measurement_concept_id", "observation_concept_id")

  # Combine results for all tables
  stats <- map2(table_names, concept_names, ~ calculate_summary_stats(cdm[[.x]], .y))
  stats <- bind_rows(stats)

  # Map concept names to the concept_ids
  concept_names <- select(cdm$concept, concept_id, concept_name) |>
    filter(concept_id %in% c(stats$concept_id, stats$value_as_concept_id)) |>
    collect()
  stats |>
    # Order is important here, first we get the names for the value_as_concept_ids
    # from the categorical data summaries and record it as `value_as_string`
    left_join(concept_names, by = c("value_as_concept_id" = "concept_id")) |>
    rename(value_as_string = concept_name) |>
    # Then we get the names for the main concept_ids
    left_join(concept_names, by = c("concept_id" = "concept_id")) |>
    select(concept_id, concept_name, !value_as_concept_id)
}


# Calculate summary stats ---------------------------------------------------------------------

# Load the data in a CDMConnector object
cdm <- CDMConnector::cdm_from_con(
  con = con,
  cdm_schema = Sys.getenv("TEST_DB_CDM_SCHEMA"),
  write_schema = Sys.getenv("TEST_DB_RESULTS_SCHEMA"),
  cdm_name = name
)

monthly_counts <- process_monthly_counts(cdm)
summary_stats <- process_summary_stats(cdm)
ids <- unique(c(monthly_counts$concept_id, summary_stats$concept_id))
concepts_table <- get_concepts_table(cdm, ids)

all_tables <- list(
  concepts = concepts_table,
  monthly_counts = monthly_counts,
  summary_stats = summary_stats
)
paths <- purrr::map_chr(names(all_tables), ~ glue::glue("{out_path}/omopcat_{.x}.parquet"))

# Write the tables to disk as parquet
purrr::walk2(all_tables, paths, ~ nanoparquet::write_parquet(.x, .y))

cli::cli_alert_success("Summary statistics generated successfully and written to {.file {fs::path_rel(paths)}}")
