#' Get Financial Quarter Start and End Dates
#'
#' @param financial_quarter vector of financial quarters
#'
#' @return a vector of financial quarter end dates and start dates
#' @export
#'
get_fq_dates <- function(data, period) {
  library(lubridate)
  dates <- data %>%
    mutate(
      record_date = yq(period) %m+% period(6, "months") %m-% days(1),
      qtr_start = yq(period) %m+% period(3, "months")
    )
}
