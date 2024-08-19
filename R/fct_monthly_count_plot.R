#' monthly_count_plot
#'
#' Generates a bar plot of the number of records per month for a given concept.
#'
#' @return A ggplot2 object containing the bar plot, or `NULL` if no data is provided.
#'
#' @importFrom ggplot2 ggplot aes geom_bar ggtitle xlab ylab
#' @noRd
monthly_count_plot <- function(monthly_counts, plot_title) {
  stopifnot(is.data.frame(monthly_counts))
  stopifnot(is.character(plot_title))
  stopifnot(all(c("date_year", "date_month", "person_count") %in% colnames(monthly_counts)))

  monthly_counts$date <- .convert_to_date(monthly_counts$date_year, monthly_counts$date_month)

  date <- person_count <- NULL
  ggplot(monthly_counts, aes(x = date, y = person_count)) +
    geom_bar(stat = "identity") +
    ggtitle(plot_title) +
    xlab("Month") +
    ylab("Number of records")
}

.convert_to_date <- function(date_year, date_month) {
  as.Date(paste0(date_year, "-", date_month, "-01"))
}
