if (interactive()) {
  suppressMessages(require("devtools"))
  suppressMessages(require("golem"))

  # warn about partial matching
  options(
    warnPartialMatchDollar = TRUE,
    warnPartialMatchAttr = TRUE,
    warnPartialMatchArgs = TRUE
  )
  options(styler.cache_root = "styler_perm")
}

source("renv/activate.R")

# Path to download Eunomia datasets
Sys.setenv(EUNOMIA_DATA_FOLDER = file.path("dev/test_db/eunomia"))
# Name of the synthetic dataset to use
Sys.setenv(TEST_DB_NAME = "synthea-allergies-10k")
# OMOP CDM version
Sys.setenv(TEST_DB_OMOP_VERSION = "5.3")
# Schema name for data
Sys.setenv(TEST_DB_CDM_SCHEMA = "main")
# Schema name for results
Sys.setenv(TEST_DB_RESULTS_SCHEMA = "main")
# Low frequency threshold for stats
Sys.setenv(LOW_FREQUENCY_THRESHOLD = "5")
# Low frequency replacement value for stats
Sys.setenv(LOW_FREQUENCY_REPLACEMENT = "2.5")
