#' Create demographic test flags
#'
#' @description Create the demographic flags for testing
#'
#' @param data a dataframe containing demographic variables e.g. chi
#' @param chi Specify chi or anon_chi.
#'
#' @return a dataframe with flag (1 or 0) for each demographic variable.
#' Missing value flag from [is_missing()]
#'
#' @family flag functions
create_demog_test_flags <- function(data, chi = c(chi, anon_chi)) {
  data %>%
    dplyr::arrange({{ chi }}) %>%
    # create test flags
    dplyr::mutate(
      unique_chi = dplyr::lag({{ chi }}) != {{ chi }},
      n_missing_chi = is_missing({{ chi }}),
      n_males = .data$gender == 1L,
      n_females = .data$gender == 2L,
      n_postcode = !is.na(.data$postcode) | !.data$postcode == "",
      n_missing_postcode = is_missing(.data$postcode),
      missing_dob = is.na(.data$dob)
    )
}
