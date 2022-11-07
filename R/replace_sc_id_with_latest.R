#' Replace sc id with the latest sc id
#'
#' @param data a dataframe containing the required variables
#'
#' @return a dataframe overwritten with the latest sc id.
#'
#' @export
#'
replace_sc_id_with_latest <- function(data) {
  # Check for required variables
  check_variables_exist(data, c("sending_location", "social_care_id", "chi", "period"))

  # select variables we need
  filter_data <- data %>%
    dplyr::select(
      "sending_location", "social_care_id", "chi", "period"
    )

  change_sc_id <- filter_data %>%
    # Sort (by sending_location, chi and period) for unique chi/sending location
    dplyr::arrange(sending_location, chi, desc(period)) %>%
    # Find the latest sc_id for each chi/sending location by keeping latest period
    dplyr::distinct(sending_location, chi, .keep_all = TRUE) %>%
    # Rename for latest sc id
    dplyr::rename(latest_sc_id = "social_care_id") %>%
    # drop period for matching
    dplyr::select(-"period")

  return_data <- change_sc_id %>%
    # Match back onto data
    dplyr::right_join(data, by = c("sending_location", "chi")) %>%
    # Overwrite sc id with the latest
    dplyr::mutate(social_care_id = dplyr::if_else(!is.na(.data$chi) & .data$social_care_id != .data$latest_sc_id,
      .data$latest_sc_id, .data$social_care_id
    ))

  return(return_data)
}
