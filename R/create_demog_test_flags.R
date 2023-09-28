#' Create demographic test flags
#'
#' @description Create the demographic flags for testing
#'
#' @param data a dataframe containing demographic variables e.g. chi
#'
#' @return a dataframe with flag (1 or 0) for each demographic variable.
#' Missing value flag from [is_missing()]
#'
#' @family flag functions
create_demog_test_flags <- function(data) {
  data %>%
    dplyr::arrange(.data$chi) %>%
    # create test flags
    dplyr::mutate(
      valid_chi = phsmethods::chi_check(.data$chi) == "Valid CHI",
      unique_chi = dplyr::lag(.data$chi) != .data$chi,
      n_missing_chi = is_missing(.data$chi),
      n_males = .data$gender == 1L,
      n_females = .data$gender == 2L,
      n_postcode = !is.na(.data$postcode) | !.data$postcode == "",
      n_missing_postcode = is_missing(.data$postcode),
      missing_dob = is.na(.data$dob)
    )
}
