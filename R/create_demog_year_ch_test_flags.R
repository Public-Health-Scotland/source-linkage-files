#' Create demographic test flags for year specific care home tests
#'
#' @description Create the demographic flags for testing for year specific care home tests
#'
#' @param data a dataframe containing demographic variables e.g. chi
#'
#' @return a dataframe with flag (1 or 0) for each demographic variable.
#' Missing value flag from [is_missing()]
#' @export
#'
#' @family flag functions
create_demog_year_ch_test_flags <- function(data) {
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
      missing_dob = dplyr::if_else(is.na(.data$dob), 1, 0),
      n_ch_name_missing = dplyr::if_else(.data$ch_name_missing, 1, 0),
      n_provider_1_to_5 = dplyr::if_else(.data$ch_provider_1_to_5, 1, 0),
      n_chi_provider_other = dplyr::if_else(.data$ch_provider_other, 1, 0),
      n_ch_adm_reason_missing = dplyr::if_else(.data$ch_adm_reason_missing, 1, 0),
      n_ch_nursing = dplyr::if_else(.data$ch_nursing, 1, 0)
    )
}
