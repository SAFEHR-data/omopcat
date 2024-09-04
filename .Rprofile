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

# Low frequency threshold for stats
Sys.setenv(LOW_FREQUENCY_THRESHOLD = "5")
# Low frequency replacement value for stats
Sys.setenv(LOW_FREQUENCY_REPLACEMENT = "2.5")
