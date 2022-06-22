#' Create demographic test flags
#'
#' @description Create the demographic flags for testing
#'
#' @param data a dataframe containing demographic variables e.g. chi
#'
#' @return a dataframe with flag (1 or 0) for each demographic variable.
#' Missing value flag from [is_missing()]
#' @export
#'
#' @family flag functions
create_demog_test_flags <- function(data) {
  data %>%
    dplyr::arrange(.data$chi) %>%
    # create test flags
    dplyr::mutate(
      valid_chi = dplyr::if_else(phsmethods::chi_check(.data$chi) == "Valid CHI", 1, 0),
      unique_chi = dplyr::if_else(dplyr::lag(.data$chi) != .data$chi, 1, 0),
      n_missing_chi = dplyr::if_else(is_missing(.data$chi), 1, 0),
      n_males = dplyr::if_else(.data$gender == 1, 1, 0),
      n_females = dplyr::if_else(.data$gender == 2, 1, 0),
      n_postcode = dplyr::if_else(is.na(.data$postcode) | .data$postcode == "", 0, 1),
      n_missing_postcode = dplyr::if_else(is_missing(.data$postcode), 1, 0),
      missing_dob = dplyr::if_else(is.na(.data$dob), 1, 0)
    )
}
