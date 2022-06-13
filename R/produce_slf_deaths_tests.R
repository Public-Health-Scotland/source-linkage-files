#' Produce the SLF deaths lookup tests
#'
#' @param data new or old data for testing summary
#' flags (data is from [get_slf_deaths_path()])
#
#' @return a dataframe with a count of each flag
#' from [calculate_measures()]
#' @export
#' @family produce tests functions
produce_slf_deaths_tests <- function(data) {
  data %>%
    # create test flags
    dplyr::mutate(
      n_chi = 1,
      n_death_date_nrs = dplyr::if_else(is.na(.data$death_date_NRS), 0, 1),
      n_death_date_chi = dplyr::if_else(is.na(.data$death_date_CHI), 0, 1),
      n_death_date = dplyr::if_else(is.na(.data$death_date), 0, 1)
    ) %>%
    # remove variables that are not test flags
    dplyr::select(-c(
      .data$chi,
      .data$death_date_NRS,
      .data$death_date_CHI,
      .data$death_date
    )) %>%
    # use function to sum new test flags
    calculate_measures(measure = "sum")
}
