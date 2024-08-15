#' monthly_count_plot
#'
#' @description A fct function
#'
#' @return The return value, if any, from executing the function.
#'
#' @importFrom ggplot2 ggplot aes geom_bar ggtitle xlab ylab
#'
#' @noRd
monthly_count_plot <- function(monthly_counts, name) {
  stopifnot(is.data.frame(monthly_counts))
  stopifnot(is.character(name))
  stopifnot(all(c("date", "record_count") %in% colnames(monthly_counts)))

  date <- record_count <- NULL
  ggplot(monthly_counts, aes(x = date, y = record_count)) +
    geom_bar(stat = "identity") +
    ggtitle(name) +
    xlab("Month") +
    ylab("Number of records")
}
