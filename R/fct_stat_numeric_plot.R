#' stat_numeric_plot
#'
#' @description A fct function
#'
#' @return The return value, if any, from executing the function.
#'
#' @importFrom ggplot2 ggplot aes geom_boxplot
#' @noRd
stat_numeric_plot <- function(summary_stat) {
  mean <- sd <- concept <- NULL
  ggplot(summary_stat, aes(x = concept)) +
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
