withr::local_envvar(
  "LOW_FREQUENCY_THRESHOLD" = 10,
  "LOW_FREQUENCY_REPLACEMENT" = 2.5,
  .local_envir = testthat::teardown_env()
)
