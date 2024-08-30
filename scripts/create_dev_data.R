# Master script to set up the test data
# Generates the dummy data in `inst/test_data` for running the app in dev mode by calling
# the relevant scripts in the correct order.

here::i_am("scripts/setup-test-data.R")

source(here::here("scripts/test_db/setup_test_db.R"))
source(here::here("scripts/test_db/insert_dummy_tables.R"))
source(here::here("scripts/omop_analyses/analyse_omop_cdm.R"))
source(here::here("scripts/test_db/produce_test_data.R"))
