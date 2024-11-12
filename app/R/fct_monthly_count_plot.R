#' monthly_count_plot
#'
#' Generates a bar plot of the number of records per month for a given concept.
#'
#' Expects the input data to have the following columns:
#' - `date_year`: The year of the date.
#' - `date_month`: The month of the date.
#' - `person_count`: The number of records for the given month.
#'
#' @param monthly_counts A data frame containing the monthly counts.
#'
#' @return A ggplot2 object containing the bar plot, or `NULL` if no data is provided.
#'
#' @noRd
monthly_count_plot <- function(monthly_counts) {
  stopifnot(is.data.frame(monthly_counts))
  stopifnot(all(c("date_year", "date_month", "person_count") %in% colnames(monthly_counts)))

  monthly_counts$date <- .convert_to_date(monthly_counts$date_year, monthly_counts$date_month)

  ggplot(monthly_counts, aes(x = .data$date, y = .data$record_count)) +
    geom_bar(aes(fill = .data$concept_name), stat = "identity") +
    xlab("Month") +
    ylab("Number of records") +
    labs(fill = NULL) +
    scale_x_date(date_labels = "%b %Y", date_breaks = "3 months") +
    theme(legend.position = "none", axis.text.x = element_text(angle = 45, hjust = 1))
}

.convert_to_date <- function(date_year, date_month) {
  as.Date(paste0(date_year, "-", date_month, "-01"))
}
