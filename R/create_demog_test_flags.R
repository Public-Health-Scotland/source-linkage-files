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
  anon_chi <- NULL
  if (!"gender" %in% names(data)) {
    data$gender <- NA_integer_
  }

  if (!"dob" %in% names(data)) {
    data$dob <- NA
  }

  if (!"postcode" %in% names(data)) {
    data$postcode <- NA_character_
  }

  data <- data %>%
    dplyr::arrange(.data$anon_chi) %>%
    dplyr::mutate(
      unique_anon_chi = dplyr::lag(.data$anon_chi) != .data$anon_chi,
      n_missing_chi = is_missing(.data$anon_chi),
      n_males = .data$gender == 1L,
      n_females = .data$gender == 2L,
      n_postcode = !is.na(.data$postcode) | .data$postcode != "",
      n_missing_postcode = is_missing(.data$postcode),
      missing_dob = is.na(.data$dob)
    )
  # fix first value always NA, and it should always be TRUE
  data[1, "unique_anon_chi"] <- TRUE
  return(data)
}
