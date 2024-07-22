#' Replace sc id with the latest sc id
#'
#' @param data a dataframe containing the required variables
#'
#' @return a dataframe overwritten with the latest sc id.
replace_sc_id_with_latest <- function(data) {
  # Check for required variables
  check_variables_exist(
    data,
    c("sending_location", "social_care_id", "chi", "latest_flag")
  )

  # select variables we need
  filter_data <- data %>%
    dplyr::select(
      "sending_location", "social_care_id", "chi", "latest_flag"
    ) %>%
    dplyr::filter(!(is.na(.data$chi))) %>%
    dplyr::distinct()

  change_sc_id <- filter_data %>%
    dplyr::filter(latest_flag == 1) %>%
    # Rename for latest sc id
    dplyr::rename(latest_sc_id = "social_care_id") %>%
    # drop latest_flag for matching
    dplyr::select(-"latest_flag")

  return_data <- change_sc_id %>%
    # Match back onto data
    dplyr::right_join(data,
      by = c("sending_location", "chi"),
      multiple = "all"
    ) %>%
    dplyr::filter(!(is.na(period))) %>%
    # Overwrite sc id with the latest
    dplyr::mutate(
      social_care_id = dplyr::if_else(
        !is.na(.data$chi) & .data$social_care_id != .data$latest_sc_id,
        .data$latest_sc_id,
        .data$social_care_id
      )
    )
  return(return_data)
}
