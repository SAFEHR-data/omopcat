#' Helper function to replace low frequencies
#'
#' Replaces frequencies below the given `threshold` with the value given by the `replacement`
#' argument. These values are typically set by the `LOW_FREQUENCY_THRESHOLD`
#' and `LOW_FREQUENCY_REPLACEMENT` environment variables. This is done to avoid identifiability
#' of the health records.
#' Values equal to zero are filtered out prior to replacement.
#'
#' @param df A data.frame
#' @param cols A character vector of column names for which to apply the replacement
#' @param threshold Threshold value below which values will be replaced by `replacement`
#' @param replacement Value with which values below `threshold` will be replaced
#'
#' @return A numeric vector with low frequencies replaced
#' @keywords internal
replace_low_frequencies <- function(df, cols, threshold, replacement) {
  threshold <- .as_numeric(threshold, "threshold")
  replacement <- .as_numeric(replacement, "replacement")

  # Remove records with values equal to 0
  df <- dplyr::filter(df, dplyr::if_all(dplyr::all_of(cols), ~ . > 0))

  # Replace values below the threshold with the replacement value
  dplyr::mutate(
    df, dplyr::across(
      dplyr::all_of(cols),
      ~ ifelse(.x < threshold, replacement, .x)
    )
  )
}

# Turn "NAs introduced by coercion" warnings into error
.as_numeric <- function(x, arg, call = rlang::caller_env()) {
  tryCatch(as.numeric(x),
    warning = function(cnd) {
      cli::cli_abort(c(
        "{.arg {arg}} is not a valid number.",
        "x" = "Got {.var {arg}} = {x}"
      ), call = call)
    }
  )
}
