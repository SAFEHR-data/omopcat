withr::local_envvar(
  EUNOMIA_DATA_FOLDER = testthat::test_path("../../data-raw/test_db"),
  .local_envir = testthat::teardown_env()
)
