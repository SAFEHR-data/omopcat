## Updates the dummy data concepts so that we have concepts for which we have bundle information

library(tidyverse)
library(omopcat)
library(omopbundles)
library(rlang)

here::i_am("data-raw/test_db/dummy/add_dummy_bundle_concepts.R")
db_path <- here::here("data-raw/test_db/eunomia/synthea-allergies-10k_5.3_1.0.duckdb")

con <- connect_to_db(db_path)
eunomia_cdm <- CDMConnector::cdmFromCon(
  con = con,
  cdmSchema = "main",
  writeSchema = "main",
  cdmName = "synthea-allergies-10k"
)
eunomia_concepts <- eunomia_cdm$concept |> dplyr::pull(concept_id)

## Get all concept IDs as integer vectors from bundles
bundle_concepts <- map(set_names(c("measurement", "observation")), function(domain) {
  bundles <- available_bundles() |> filter(domain == {{ domain }})
  map(bundles$id, ~ concept_by_bundle(domain = domain, id = .x)$concept_id) |>
    unlist() |>
    unique()
})

## Keep only concepts that appear in the Eunomia CDM
keep_concepts <- map(bundle_concepts, ~ .x[.x %in% eunomia_concepts])

## Read current dummy tables and replace concept IDs with new IDs
## for which we have bundle information
measurement <- read_csv("data-raw/test_db/dummy/measurement.csv")
observation <- read_csv("data-raw/test_db/dummy/observation.csv")

replace_concepts <- function(x, concept_id_name, concepts_to_keep) {
  concepts <- unique(x[[concept_id_name]])
  concepts_map <- concepts_to_keep[seq_along(length(concepts))]
  names(concepts_map) <- concepts

  x |>
    mutate("{concept_id_name}" := concepts_map[as.character(.data[[concept_id_name]])]) # nolint
}

new_measurements <- replace_concepts(measurement, "measurement_concept_id", keep_concepts$measurement)
new_observations <- replace_concepts(observation, "observation_concept_id", keep_concepts$observation)

## Sanity check
stopifnot(all(new_measurements$measurement_concept_id %in% bundle_concepts$measurement))
stopifnot(all(new_observations$observation_concept_id %in% bundle_concepts$observation))

## Write new dummy tables
write_csv(new_measurements, "data-raw/test_db/dummy/measurement.csv")
write_csv(new_observations, "data-raw/test_db/dummy/observation.csv")
