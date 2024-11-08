#' Helper function to replace low frequencies
#'
#' Replaces frequencies below a certain threshold with a new value, based on the
#' `LOW_FREQUENCY_THRESHOLD` and `LOW_FREQUENCY_REPLACEMENT` environment variables.
#'
#' @param x A numeric vector
#'
#' @return A numeric vector with low frequencies replaced
#'
#' @noRd
replace_low_frequencies <- function(x) {
  threshold <- as.double(Sys.getenv("LOW_FREQUENCY_THRESHOLD"))
  replacement <- as.double(Sys.getenv("LOW_FREQUENCY_REPLACEMENT"))

  stopifnot("LOW_FREQUENCY_THRESHOLD is not a valid number" = !is.na(threshold))
  stopifnot("LOW_FREQUENCY_REPLACEMENT is not a valid number" = !is.na(replacement))

  ifelse(x < threshold, replacement, x)
}
