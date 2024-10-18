# Master script to set up the test data
# Generates the dummy data in `inst/test_data` for running the app in dev mode by calling
# the relevant scripts in the correct order.

here::i_am("scripts/create_dev_data.R")

Sys.setenv("ENV" = "dev")
# Path to download Eunomia datasets
Sys.setenv(EUNOMIA_DATA_FOLDER = file.path("data-raw/test_db/eunomia"))
# Name of the synthetic dataset to use
Sys.setenv(TEST_DB_NAME = "synthea-allergies-10k")
# OMOP CDM version
Sys.setenv(TEST_DB_OMOP_VERSION = "5.3")
# Schema name for data and results
Sys.setenv(DB_CDM_SCHEMA = "main")

source(here::here("scripts/01_setup_test_db.R"))
source(here::here("scripts/02_insert_dummy_tables.R"))
source(here::here("scripts/03_analyse_omop_cdm.R"))
source(here::here("scripts/04_produce_dev_data.R"))
