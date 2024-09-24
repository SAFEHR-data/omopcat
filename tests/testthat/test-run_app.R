test_that("Env check fails when envvars missing", {
  withr::local_envvar(OMOPCAT_DATA_PATH = NULL)
  expect_error(.check_env(), "The following environment variables are missing: `OMOPCAT_DATA_PATH`")
})
