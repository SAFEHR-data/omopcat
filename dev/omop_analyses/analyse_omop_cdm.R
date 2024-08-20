
library(tidyverse)

dir <- Sys.getenv("EUNOMIA_DATA_FOLDER")
name <- Sys.getenv("TEST_DB_NAME")
version <- Sys.getenv("TEST_DB_OMOP_VERSION")

# Connect to the duckdb test database
con <- DBI::dbConnect(duckdb::duckdb(
  dbdir = glue::glue("{dir}/{name}_{version}_1.0.duckdb")))

# Function to execute one or more SQL queries and clear results
create_results_tables <- function(con, sql) {
  # Execute sql query
  result <- DBI::dbSendStatement(con, sql)
  # Clear results
  DBI::dbClearResult(result)
}

# Function to produce the 'calypso_concepts' table
# from a list of concept ids
analyse_concepts <- function(cdm, concepts) {
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

# Function to produce the 'calypso_monthly_counts' table
analyse_monthly_counts <- function(cdm) {
  # Function to analyse a column from a specific table
  # for each month
  analyse_table <- function(table, concept, date) {
    # Extract year and month from date column
    table <- table |>
      mutate(
        concept_id = {{ concept }},
        date_year = lubridate::year({{ date }}),
        date_month = lubridate::month({{ date }})
      )
    # Get total count for each month
    total_count <- table |>
      select(concept_id, date_year, date_month) |>
      collect() |>
      group_by(date_year, date_month, concept_id) |>
      count(name = "total_count")
    # Get number of unique patients per concept for each month
    person_count <- table |>
      select(concept_id, date_year, date_month, person_id) |>
      collect() |>
      group_by(date_year, date_month, concept_id) |>
      reframe(person_count = n_distinct(person_id))
    # Get number of records per person for each month
    table |>
      select(concept_id, date_year, date_month) |>
      distinct() |>
      collect() |>
      inner_join(total_count, join_by(date_year, date_month, concept_id)) |>
      inner_join(person_count, join_by(date_year, date_month, concept_id)) |>
      mutate(records_per_person = (total_count / person_count)) |>
      select(
        concept_id,
        date_year,
        date_month,
        person_count,
        records_per_person
      )
  }
  # Combine results for all tables
  bind_rows(
    cdm$condition_occurrence |> analyse_table(condition_concept_id, condition_start_date),
    cdm$drug_exposure |> analyse_table(drug_concept_id, drug_exposure_start_date),
    cdm$procedure_occurrence |> analyse_table(procedure_concept_id, procedure_date),
    cdm$device_exposure |> analyse_table(device_concept_id, device_exposure_start_date),
    cdm$measurement |> analyse_table(measurement_concept_id, measurement_date),
    cdm$observation |> analyse_table(observation_concept_id, observation_date),
    cdm$specimen |> analyse_table(specimen_concept_id, specimen_date)
  )
}

# Function to produce the 'calypso_summary_stats' table
analyse_summary_stats <- function(cdm) {
  # Function to analyse a numeric column
  # by calculation the mean and the standard deviation
  analyse_numeric_column <- function(table, concept, value) {
    # Rename columns and remove empty values
    table <- table |>
      select(concept_id = {{ concept }}, value = {{ value }}) |>
      filter(!is.na(value)) |>
      collect()
    # Calculate mean
    df_mean <- table |>
      group_by(concept_id) |>
      reframe(
        summary_attribute = "mean",
        value_as_number = mean(value)
      )
    # Calculate standard deviation
    df_sd <- table |>
      group_by(concept_id) |>
      reframe(
        summary_attribute = "sd",
        value_as_number = sd(value)
      )
    # Combine mean and standard deviation
    bind_rows(df_mean, df_sd)
  }

  # Function to analyse a categorical column - present in observation and measurement
  # by joining value_as_concept_id to cdm$concept by concept_id
  analyse_categorical_column <- function(cdm, table, concept, value) {
    # Rename columns and remove empty values
    table <- table |>
      select(concept_id = {{ concept }}, value = {{ value }}) |>
      filter(!is.na(value)) |>
      collect()
    # count freq and join to concept table to get name
    df_freq_val_as_concept_named <- table |>
      # beware CDM docs: NULL=no categorical result, 0=categorical result but no mapping
      filter(value_as_concept_id != 0 & !is.null(value_as_concept_id)) |>
      count(concept_id, value) |>
      left_join(select(cdm$concept, concept_id, concept_name),
                by = c('value_as_concept_id' = 'concept_id')) |>
      mutate(concept_id = concept_id,
             #TODO as agreed 2024-08-16 enable concept_name here and in analyse_numeric_column
             #OR could join concept_name at end of analyse_summary_stats()
             #concept_name = concept_name,
             summary_attribute = "frequency",
             value_as_string = value_as_concept_name,
             value = n,
             .keep="none")
  }

  # Combine results for all columns
  bind_rows(
    #numeric results
    cdm$measurement |> analyse_numeric_column(measurement_concept_id, value_as_number),
    cdm$observation |> analyse_numeric_column(observation_concept_id, value_as_number),
    #categorical results
    cdm$measurement |> analyse_categorical_column(cdm, measurement_concept_id, value_as_concept_id),
    cdm$observation |> analyse_categorical_column(cdm, observation_concept_id, value_as_concept_id)
  )
}

# Function to write result to the results schema
write_results <- function(data, con, table) {
  # Insert data into the specified table
  # (in the results schema)
  DBI::dbWriteTable(
    conn = con,
    name = DBI::Id(
      schema = Sys.getenv("TEST_DB_RESULTS_SCHEMA"),
      table = table
    ),
    value = data,
    append = TRUE,
    overwrite = FALSE
  )
}

# Retrieve SQL query to create Calypso tables
# (using the results schema)
sql <- gsub(
  "@resultsDatabaseSchema",
  Sys.getenv("TEST_DB_RESULTS_SCHEMA"),
  readr::read_file(here::here("dev/omop_analyses/calypso_tables.sql"))
)

# Create the Calypso tables to the results schema
create_results_tables(con, sql)

# Load the data in a CDMConnector object
cdm <- CDMConnector::cdm_from_con(
  con = con,
  cdm_schema = Sys.getenv("TEST_DB_CDM_SCHEMA"),
  write_schema = Sys.getenv("TEST_DB_RESULTS_SCHEMA"),
  cdm_name = name
)

# Generate monthly counts and write it to the DB
monthly_counts <- analyse_monthly_counts(cdm)
monthly_counts |>
  write_results(con, "calypso_monthly_counts")

# Generate summary stats and write it to the DB
summary_stats <- analyse_summary_stats(cdm)
summary_stats |>
  write_results(con, "calypso_summary_stats")

# Get list of concept ids
ids <- bind_rows(
  { monthly_counts |> select(concept_id) },
  { summary_stats |> select(concept_id) }
) |> distinct()
ids <- ids$concept_id

# Retrieve concept properties from the list of ids
analyse_concepts(cdm, ids) |>
  write_results(con, "calypso_concepts")

# Clean up
DBI::dbDisconnect(con)
rm(create_results_tables)
rm(analyse_concepts)
rm(analyse_monthly_counts)
rm(analyse_summary_stats)
rm(write_results)
rm(monthly_counts)
rm(summary_stats)
rm(ids)
rm(cdm)
rm(con)
rm(sql)
rm(dir)
rm(name)
rm(version)

detach("package:tidyverse", unload = TRUE)
