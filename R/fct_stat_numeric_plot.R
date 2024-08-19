#' stat_numeric_plot
#'
#' Generates a boxplot of the summary statistics for a numeric concept.
#' Uses pre-calculated `mean` and `sd` to generate the boxplot.
#'
#' Expects the input data to have the following columns:
#' - `concept_id`: The concept ID.
#' - `summary_attribute`: The type of the summary attribute, e.g. `mean` or `sd`.
#' - `value_as_number`: The value of the summary attribute as a numeric value.
#'
#' @param summary_stats A data frame containing the summary statistics.
#'
#' @return A `ggplot2` object.
#'
#' @importFrom ggplot2 ggplot aes geom_boxplot
#' @noRd
stat_numeric_plot <- function(summary_stats) {
  processed_stats <- .process_summary_stats(summary_stats)

  mean <- sd <- concept_id <- NULL
  ggplot(processed_stats, aes(x = concept_id)) +
    geom_boxplot(
      aes(
        lower = mean - sd,
        upper = mean + sd,
        middle = mean,
        ymin = mean - 3 * sd,
        ymax = mean + 3 * sd
      ),
      stat = "identity"
    )
}

.process_summary_stats <- function(summary_stats) {
  # We expect only single concept ID at this point
  stopifnot("Expecting a single concept ID" = length(unique(summary_stats$concept_id)) == 1)
  stopifnot(c("concept_id", "summary_attribute", "value_as_number") %in% names(summary_stats))

  tidyr::pivot_wider(summary_stats,
    id_cols = "concept_id",
    names_from = "summary_attribute",
    values_from = "value_as_number"
  )
}
