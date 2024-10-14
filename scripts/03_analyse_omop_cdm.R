cli::cli_h1("Generating summarys statistics")


# Setup ---------------------------------------------------------------------------------------

library(omopcat)

if (Sys.getenv("ENV") == "prod") {
  name <- Sys.getenv("DB_NAME")
  con <- connect_to_db(
    RPostgres::Postgres(),
    dbname = Sys.getenv("DB_NAME"),
    host = Sys.getenv("HOST"),
    port = Sys.getenv("PORT"),
    user = Sys.getenv("DB_USERNAME"),
    password = Sys.getenv("DB_PASSWORD")
  )
  fs::dir_create(
    out_path <- here::here("data/prod_data")
  )
} else {
  dir <- Sys.getenv("EUNOMIA_DATA_FOLDER")
  name <- Sys.getenv("TEST_DB_NAME")
  version <- Sys.getenv("TEST_DB_OMOP_VERSION")

  db_path <- glue::glue("{dir}/{name}_{version}_1.0.duckdb")
  con <- connect_to_test_duckdb(db_path)

  fs::dir_create(
    out_path <- here::here("data/test_data")
  )
}

# Calculate summary stats ---------------------------------------------------------------------

# Load the data in a CDMConnector object
cdm <- CDMConnector::cdm_from_con(
  con = con,
  cdm_schema = Sys.getenv("DB_CDM_SCHEMA"),
  write_schema = Sys.getenv("DB_CDM_SCHEMA"),
  cdm_name = name
)

cli::cli_progress_step("Calculating monthly counts...")
monthly_counts <- process_monthly_counts(cdm)
cli::cli_progress_step("Calculating summary statistics...")
summary_stats <- process_summary_stats(cdm)
ids <- unique(c(monthly_counts$concept_id, summary_stats$concept_id))
concepts_table <- query_concepts_table(cdm, ids)

all_tables <- list(
  concepts = concepts_table,
  monthly_counts = monthly_counts,
  summary_stats = summary_stats
)
paths <- purrr::map_chr(names(all_tables), ~ glue::glue("{out_path}/omopcat_{.x}.parquet"))

# Write the tables to disk as parquet
purrr::walk2(all_tables, paths, ~ nanoparquet::write_parquet(.x, .y))

cli::cli_alert_success("Summary statistics generated successfully and written to {.file {fs::path_rel(paths)}}")
