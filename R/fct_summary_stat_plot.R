#' summary_stat_plot
#'
#' Wrapper function to generate a plot for a summary statistic depending on its type
#' (categorical or numeric).
#'
#' @param summary_stats A `data.frame` containing the summary statistics.
#' @param plot_title A `character`, to be used as title of the plot.
#'
#' @return A `ggplot2` object.
#'
#' @noRd
summary_stat_plot <- function(summary_stats, plot_title) {
  if (.is_categorical(summary_stats)) {
    stat_categorical_plot(summary_stats, plot_title)
  } else {
    stat_numeric_plot(summary_stats, plot_title)
  }
}

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
#' @param summary_stats A `data.frame` containing the summary statistics.
#' @param plot_title A `character`, to be used as title of the plot.
#'
#' @return A `ggplot2` object.
#'
#' @importFrom ggplot2 ggplot aes geom_boxplot theme
#' @noRd
stat_numeric_plot <- function(summary_stats, plot_title) {
  processed_stats <- .process_numeric_stats(summary_stats)

  ggplot(processed_stats, aes(x = factor(.data$concept_id), fill = factor(.data$concept_id))) +
    geom_boxplot(
      aes(
        lower = .data$mean - .data$sd,
        upper = .data$mean + .data$sd,
        middle = .data$mean,
        ymin = .data$mean - 3 * .data$sd,
        ymax = .data$mean + 3 * .data$sd,
      ),
      stat = "identity"
    ) +
    xlab(NULL) +
    ggtitle(plot_title) +
    theme(legend.position = "none")
}

#' stat_categorical_plot
#'
#' Generates a bar plot of the category frequencies for a categorical concept.
#' Uses pre-calculated frequencies to generate the plot.
#'
#' Expects the input data to have the following columns:
#' - `concept_id`: The concept ID.
#' - `summary_attribute`: The type of the summary attribute, should be 'frequency'.
#' - `value_as_string`: The name of the category
#' - `value_as_number`: The value of the summary attribute as a numeric value.
#'
#' @param summary_stats A `data.frame` containing the summary statistics.
#' @param plot_title A `character`, to be used as title of the plot.
#'
#' @return A `ggplot2` object.
#'
#' @importFrom ggplot2 ggplot aes geom_col labs facet_wrap vars
#' @noRd
stat_categorical_plot <- function(summary_stats, plot_title) {
  stopifnot(c("concept_id", "value_as_string", "value_as_number") %in% names(summary_stats))

  summary_stats$value_as_string <- as.factor(summary_stats$value_as_string)
  # Reorder factor levels by frequency
  summary_stats$value_as_string <- forcats::fct_reorder(
    summary_stats$value_as_string, summary_stats$value_as_number,
    .desc = TRUE
  )

  ggplot(summary_stats, aes(.data$value_as_string, .data$value_as_number)) +
    geom_col(aes(fill = .data$value_as_string), show.legend = FALSE) +
    labs(x = "Category", y = "Frequency") +
    ggtitle(plot_title) +
    facet_wrap(vars(.data$concept_name), scales = "free")
}

.process_numeric_stats <- function(summary_stats) {
  stopifnot(c("concept_id", "summary_attribute", "value_as_number") %in% names(summary_stats))

  tidyr::pivot_wider(summary_stats,
    id_cols = "concept_id",
    names_from = "summary_attribute",
    values_from = "value_as_number"
  )
}

.is_categorical <- function(summary_stats) {
  "frequency" %in% summary_stats$summary_attribute
}
