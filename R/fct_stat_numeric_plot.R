#' stat_numeric_plot
#'
#' @description A fct function
#'
#' @return The return value, if any, from executing the function.
#'
#' @importFrom ggplot2 ggplot aes geom_boxplot
#' @noRd
stat_numeric_plot <- function(summary_stats) {
  mean <- sd <- concept_id <- NULL
  processed_stats <- .process_summary_stats(summary_stats)
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
  stopifnot(c("concept_id", "summary_attribute", "values_from") %in% names(summary_stats))

  tidyr::pivot_wider(summary_stats,
    id_cols = "concept_id",
    names_from = "summary_attribbute",
    values_from = "value_as_number"
  )
}
