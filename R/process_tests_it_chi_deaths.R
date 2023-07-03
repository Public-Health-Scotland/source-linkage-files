#' Process CHI Deaths tests
#'
#' @inherit process_tests_lookup_pc
#'
#' @export
process_tests_it_chi_deaths <- function(data, update = previous_update()) {
  comparison <- produce_test_comparison(
    old_data = produce_it_chi_deaths_tests(
      read_file(get_slf_chi_deaths_path(update = update))
    ),
    new_data = produce_it_chi_deaths_tests(data)
  ) %>%
    write_tests_xlsx(sheet_name = "it_chi_deaths")

  return(comparison)
}

#' CHI death tests
#'
#' @description Produce the tests for IT CHI deaths
#'
#' @param data new or old data for testing summary
#' flags (data is from [get_slf_chi_deaths_path()])
#
#' @return a dataframe with a count of each flag
#' from [calculate_measures()]
#' @family slf test functions
produce_it_chi_deaths_tests <- function(data) {
  data %>%
    # create test flags
    dplyr::mutate(
      n_chi = 1L,
      n_death_date_nrs = dplyr::if_else(is.na(.data$death_date_NRS), 0L, 1L),
      n_death_date_chi = dplyr::if_else(is.na(.data$death_date_CHI), 0L, 1L),
      n_death_date = dplyr::if_else(is.na(.data$death_date), 0L, 1L)
    ) %>%
    # remove variables that are not test flags
    dplyr::select(-c(
      "chi",
      "death_date_NRS",
      "death_date_CHI",
      "death_date"
    )) %>%
    # use function to sum new test flags
    calculate_measures(measure = "sum")
}
