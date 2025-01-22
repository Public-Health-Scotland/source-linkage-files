#' Process CHI Deaths tests
#'
#' @inherit process_tests_lookup_pc
#'
#' @export
process_tests_it_chi_deaths <- function(data, update = previous_update()) {
  comparison <- produce_test_comparison(
    old_data = produce_it_chi_deaths_tests(
      read_file(get_slf_chi_deaths_path(update = update))),
    new_data = produce_it_chi_deaths_tests(data)
  ) %>%
    write_tests_xlsx(sheet_name = "it_chi_deaths", workbook_name = "lookup")

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
  current_year_0 <- lubridate::year(Sys.Date())
  current_year_1 <- lubridate::year(Sys.Date()) - 1L
  current_year_2 <- lubridate::year(Sys.Date()) - 2L
  current_year_3 <- lubridate::year(Sys.Date()) - 3L
  current_year_4 <- lubridate::year(Sys.Date()) - 4L
  current_year_5 <- lubridate::year(Sys.Date()) - 5L

  data %>%
    # change to chi for phsmethods
    slfhelper::get_chi() %>%
    # create test flags
    dplyr::mutate(
      n_chi = 1L,
      n_valid_chi = phsmethods::chi_check(.data$chi) == "Valid CHI",
      n_death_date_chi = is.na(.data$death_date_chi),
      death_year = lubridate::year(.data$death_date_chi),
      "n_deaths_{current_year_0}" := .data$death_year == current_year_0,
      "n_deaths_{current_year_1}" := .data$death_year == current_year_1,
      "n_deaths_{current_year_2}" := .data$death_year == current_year_2,
      "n_deaths_{current_year_3}" := .data$death_year == current_year_3,
      "n_deaths_{current_year_4}" := .data$death_year == current_year_4,
      "n_deaths_{current_year_5}" := .data$death_year == current_year_5
    ) %>%
    # remove variables that are not test flags
    dplyr::select(dplyr::starts_with("n_")) %>%
    # use function to sum new test flags
    calculate_measures(measure = "sum")
}
