#' Add financial year from Social Care period
#' Financial year format, eg 2024
#' @param data social care data frame
#'
#' @returns social care data frame with financial year and financial quarter
add_fy_qtr_from_period <- function(data) {
  data %>%
    # create financial_year and financial_quarter variables for sorting
    dplyr::mutate(
      financial_year = as.numeric(stringr::str_sub(.data$period, 1, 4)),
      financial_quarter = stringr::str_sub(.data$period, 6, 6)
    ) %>%
    # set financial quarter to 5 when there is only an annual submission -
    # for ordering periods with annual submission last
    dplyr::mutate(
      financial_quarter = dplyr::if_else(
        is.na(.data$financial_quarter) |
          .data$financial_quarter == "",
        "5",
        .data$financial_quarter
      )
    )
}


#' which_fy
#' Extract financial year from a date
#'
#' @param date a date variable
#' @param format calenddar year format 2024, or financial year format, 2425
#' @returns financial year
which_fy <- function(date, format = c("year", "fyear")) {
  year <- as.numeric(format(date, "%Y"))
  month <- as.numeric(format(date, "%m"))

  start_year <- ifelse(month < 4, year - 1, year)
  end_year <- start_year + 1
  if (format == "year") {
    return(start_year)
  } else {
    return(paste0(substr(start_year, 3, 4), substr(end_year, 3, 4)))
  }
}
