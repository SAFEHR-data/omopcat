withr::local_envvar(
  "LOW_FREQUENCY_THRESHOLD" = 10,
  "LOW_FREQUENCY_REPLACEMENT" = 2.5,
  "OMOPCAT_DATA_PATH" = NULL, # make sure we use the dev data for tests
  .local_envir = testthat::teardown_env()
)
