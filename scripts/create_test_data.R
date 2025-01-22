# Generates the parquet files in data/test_data/ by running the preprocessing pipeilne
# on the test database located at data-raw/test_db/eunomia
withr::local_envvar(
  ENV = "test",
  EUNOMIA_DATA_FOLDER = here::here("data-raw/test_db/eunomia"),
  DB_NAME = "synthea-allergies-10k",
  DB_CDM_SCHEMA = "main",
  LOW_FREQUENCY_THRESHOLD = 5,
  LOW_FREQUENCY_REPLACEMENT = 2.5
)

out_path <- here::here("data/test_data/internal")
omopcat.preprocessing::preprocess(out_path)

cli::cli_alert_success("Test data written to {out_path}")
