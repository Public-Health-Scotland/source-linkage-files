
replace_sc_id_with_latest <- function(data) {
  # Check for required variables
  check_variables_exist(data, c("sending_location", "social_care_id", "chi", "period"))

  # select variables we need
  filter_data <- matched_hc_data %>%
    dplyr::select(
      "sending_location", "social_care_id", "chi", "period"
    ) %>%
    # Filter to CHIs with multiple sc_id per sending loc
    dplyr::group_by(.data$sending_location, .data$social_care_id) %>%
    dplyr::mutate(latest_sc_id = dplyr::last(.data$social_care_id)) %>%
    # count changed social_care_id
    dplyr::mutate(
      changed_sc_id = dplyr::if_else(!is.na(.data$chi) & .data$social_care_id != .data$latest_sc_id, 1, 0),
      social_care_id = dplyr::if_else(!is.na(.data$chi) & .data$social_care_id != .data$latest_sc_id,
        .data$latest_sc_id, .data$social_care_id
      )
    ) %>%
    dplyr::ungroup()

  # Sort (by period?) to find the latest sc_id for each CHI / sending_loc

  # match that back to the data overwriting the older one.

  # Return the data (no new variables added, just overwrite the sc_id)
}
