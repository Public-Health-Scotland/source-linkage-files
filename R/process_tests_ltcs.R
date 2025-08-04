#' Process LTCs tests
#'
#' @description This script takes the processed LTCs extract and produces
#' a test comparison with the previous data. This is written to disk as an xlsx.
#'
#' @inherit process_tests_acute
#'
#' @export
process_tests_ltcs <- function(data, year) {
  old_data <- read_file(get_ltcs_path_older_update(year))

  comparison <- produce_test_comparison(
    old_data = produce_source_ltc_tests(old_data),
    new_data = produce_source_ltc_tests(data)
  ) %>%
    dplyr::mutate(recid = "LTCs") %>%
    write_tests_xlsx(sheet_name = "ltc", year = year, workbook_name = "extract")

  return(comparison)
}


#' LTC Episodes Tests
#'
#' @description Produce the test for the Long Term Conditions (LTCs) all episodes
#'
#' @param data new or old data for testing summary flags
#' (data is from [get_ltc_path()] or [get_ltc_path_older_update()])
#' @return a dataframe with a count of each flag.
#'
#' @family social care test functions
produce_source_ltc_tests <- function(data) {
  ltc_vars <- slfhelper::ltc_vars
  ltc_vars2 <- c("anon_chi", ltc_vars)
  ltc_dates <- paste0(ltc_vars, "_date")

  join_output <- data %>%
    dplyr::summarise(
      chi = nrow(data),
      unique_chi = dplyr::n_distinct(.data$anon_chi),
      # Sum each LTC variable
      dplyr::across(dplyr::all_of(ltc_vars), ~ sum(.x, na.rm = TRUE)),
      # Min of each ltc_date column
      dplyr::across(
        dplyr::all_of(ltc_dates),
        ~ convert_date_to_numeric(min(.x, na.rm = TRUE)),
        .names = "{.col}_min"
      ),
      # Max of each ltc_date column
      dplyr::across(
        dplyr::all_of(ltc_dates),
        ~ convert_date_to_numeric(max(.x, na.rm = TRUE)),
        .names = "{.col}_max"
      ),
      # Mean of each ltc_date column
      dplyr::across(
        dplyr::all_of(ltc_dates),
        ~ convert_date_to_numeric(as.Date(mean(
          as.numeric(.x),
          na.rm = TRUE
        ), origin = "1970-01-01")),
        .names = "{.col}_mean"
      ),
      # Standard deviation in days for each date column
      dplyr::across(dplyr::all_of(ltc_dates), ~ as.integer(sd(
        as.numeric(.x),
        na.rm = TRUE
      )), .names = "{.col}_sd")
    ) %>%
    tidyr::pivot_longer(
      cols = dplyr::everything(),
      names_to = "measure",
      values_to = "value"
    )

  return(join_output)
}
