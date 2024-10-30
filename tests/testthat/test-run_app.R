test_that("app launches without errors", {
  golem::expect_running(sleep = 5)
})

test_that("app ui is set up correctly", {
  ui <- app_ui()
  golem::expect_shinytaglist(ui)
  # Check that formals have not been removed
  fmls <- formals(app_ui)
  for (i in c("request")) {
    expect_true(i %in% names(fmls))
  }
})

test_that("app server is set up correctly", {
  server <- app_server
  expect_type(server, "closure")
  # Check that formals have not been removed
  fmls <- formals(app_server)
  for (i in c("input", "output", "session")) {
    expect_true(i %in% names(fmls))
  }
})

test_that("app_sys works", {
  expect_true(app_sys("golem-config.yml") != "")
})

test_that("golem-config works", {
  config_file <- app_sys("golem-config.yml")
  skip_if(config_file == "")

  expect_true(get_golem_config("app_prod", config = "production", file = config_file))
  expect_false(get_golem_config("app_prod", config = "dev", file = config_file))
})

test_that("Running app in prod fails if data path not set", {
  withr::local_envvar(
    GOLEM_CONFIG_ACTIVE = "production",
    OMOPCAT_DATA_PATH = NULL
  )
  expect_error(
    run_app(),
    "Environment variable `OMOPCAT_DATA_PATH` not set"
  )
})
