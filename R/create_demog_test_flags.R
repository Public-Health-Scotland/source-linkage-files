#' Create demographic test flags
#'
#' @param data a dataframe containing demographic variables e.g. chi
#'
#' @return a dataframe with flag (1 or 0) for each demographic variables.
#' Missing value flag from \code{\link{is_missing}}
#' @export
#'
#' @importFrom dplyr if_else arrange
#' @family create test flags functions
create_demog_test_flags <- function(data) {
  data %>%
    arrange(.data$chi) %>%
    # create test flags
    mutate(
      valid_chi = if_else(phsmethods::chi_check(.data$chi) == "Valid CHI",
        1, 0
      ),
      unique_chi = if_else(dplyr::lag(.data$chi) != .data$chi,
        1, 0
      ),
      n_missing_chi = if_else(is_missing(.data$chi),
        1, 0
      ),
      n_males = if_else(.data$gender == 1,
        1, 0
      ),
      n_females = if_else(.data$gender == 2,
        1, 0
      ),
      n_postcode = if_else(is.na(.data$postcode) |
        .data$postcode == "",
      0, 1
      ),
      n_missing_postcode = if_else(is_missing(.data$postcode),
        1, 0
      ),
      missing_dob = if_else(is.na(.data$dob),
        1, 0
      )
    )
}

