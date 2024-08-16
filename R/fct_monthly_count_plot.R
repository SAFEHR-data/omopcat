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
  stopifnot(all(c("date_year", "date_month", "person_count") %in% colnames(monthly_counts)))

  monthly_counts$date <- .convert_to_date(monthly_counts$date_year, monthly_counts$date_month)

  date <- person_count <- NULL
  ggplot(monthly_counts, aes(x = date, y = person_count)) +
    geom_bar(stat = "identity") +
    ggtitle(name) +
    xlab("Month") +
    ylab("Number of records")
}

.convert_to_date <- function(date_year, date_month) {
  as.Date(paste0(date_year, "-", date_month, "-01"))
}
