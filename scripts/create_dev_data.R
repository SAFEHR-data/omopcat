# Master script to set up the test data
# Generates the dummy data in `inst/test_data` for running the app in dev mode by calling
# the relevant scripts in the correct order.

here::i_am("scripts/setup-test-data.R")

# Path to download Eunomia datasets
Sys.setenv(EUNOMIA_DATA_FOLDER = file.path("data-raw/test_db/eunomia"))
# Name of the synthetic dataset to use
Sys.setenv(TEST_DB_NAME = "synthea-allergies-10k")
# OMOP CDM version
Sys.setenv(TEST_DB_OMOP_VERSION = "5.3")
# Schema name for data
Sys.setenv(TEST_DB_CDM_SCHEMA = "main")
# Schema name for results
Sys.setenv(TEST_DB_RESULTS_SCHEMA = "main")

source(here::here("scripts/setup_test_db.R"))
source(here::here("scripts/insert_dummy_tables.R"))
source(here::here("scripts/analyse_omop_cdm.R"))
source(here::here("scripts/produce_test_data.R"))
