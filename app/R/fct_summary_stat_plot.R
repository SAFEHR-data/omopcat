#' stat_numeric_plot
#'
#' Generates a boxplot of the summary statistics for numeric concepts.
#' Uses pre-calculated `mean` and `sd` to generate the boxplot.
#'
#' Expects the input data to have the following columns:
#' - `concept_id`: The concept IDs.
#' - `summary_attribute`: The type of the summary attribute, e.g. `mean` or `sd`.
#' - `value_as_number`: The value of the summary attribute as a numeric value.
#'
#' @param summary_stats A `data.frame` containing the summary statistics.
#'
#' @return A `ggplot2` object or `NULL` if no numeric concepts are present.
#'
#' @noRd
stat_numeric_plot <- function(summary_stats) {
  # Select only numeric concepts
  summary_stats <- .numeric_stats(summary_stats)
  if (nrow(summary_stats) == 0) {
    return(NULL)
  }

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
    theme(legend.position = "none")
}

#' stat_categorical_plot
#'
#' Generates a bar plot of the category frequencies for categorical concepts.
#' Uses pre-calculated frequencies to generate the plot.
#' In case of multiple concepts, a faceted plot is generated.
#'
#' Expects the input data to have the following columns:
#' - `concept_id`: The concept ID.
#' - `summary_attribute`: The type of the summary attribute, should be 'frequency'.
#' - `value_as_string`: The name of the category
#' - `value_as_number`: The value of the summary attribute as a numeric value.
#'
#' @param summary_stats A `data.frame` containing the summary statistics.
#'
#' @return A `ggplot2` object or `NULL` if no numeric concepts are present.
#'
#' @noRd
stat_categorical_plot <- function(summary_stats) {
  ## Select only categorical concepts
  summary_stats <- .categorical_stats(summary_stats)
  if (nrow(summary_stats) == 0) {
    return(NULL)
  }

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
    facet_wrap(vars(.data$concept_name), scales = "free") +
    theme(axis.text.x = element_text(angle = 45, hjust = 1))
}

.process_numeric_stats <- function(summary_stats) {
  stopifnot(c("concept_id", "summary_attribute", "value_as_number") %in% names(summary_stats))

  tidyr::pivot_wider(summary_stats,
    id_cols = "concept_id",
    names_from = "summary_attribute",
    values_from = "value_as_number"
  )
}

.categorical_stats <- function(summary_stats) {
  summary_stats[summary_stats$summary_attribute == "frequency", ]
}

.numeric_stats <- function(summary_stats) {
  summary_stats[summary_stats$summary_attribute %in% c("mean", "sd"), ]
}
