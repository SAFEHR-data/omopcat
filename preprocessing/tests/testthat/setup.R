withr::local_envvar(
  ENV = "test",
  EUNOMIA_DATA_FOLDER = testthat::test_path("../../data-raw/test_db"),
  TEST_DB_NAME = "GiBleed",
  DB_CDM_SCHEMA = "main",
  .local_envir = testthat::teardown_env()
)

mock_cdm <- .setup_cdm_object(.envir = testthat::teardown_env())
