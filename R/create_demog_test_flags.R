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
      valid_chi = dplyr::if_else(
        phsmethods::chi_check(.data$chi) == "Valid CHI",
        1L,
        0L
      ),
      unique_chi = dplyr::if_else(
        dplyr::lag(.data$chi) != .data$chi,
        1L,
        0L
      ),
      n_missing_chi = dplyr::if_else(
        is_missing(.data$chi),
        1L,
        0L
      ),
      n_males = dplyr::if_else(
        .data$gender == 1L,
        1L,
        0L
      ),
      n_females = dplyr::if_else(
        .data$gender == 2L,
        1L,
        0L
      ),
      n_postcode = dplyr::if_else(
        is.na(.data$postcode) | .data$postcode == "",
        0L,
        1L
      ),
      n_missing_postcode = dplyr::if_else(
        is_missing(.data$postcode),
        1L,
        0L
      ),
      missing_dob = dplyr::if_else(
        is.na(.data$dob),
        1L,
        0L
      )
    )
}
