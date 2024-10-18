test_that("Env check fails when envvars missing", {
  withr::local_envvar(OMOPCAT_DATA_PATH = NULL)
  expect_error(
    .check_envvars("OMOPCAT_DATA_PATH"),
    "Environment variable `OMOPCAT_DATA_PATH` not set"
  )
})
