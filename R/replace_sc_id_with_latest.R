#' Replace sc id with the latest sc id
#'
#' @param data a dataframe containing the required variables
#'
#' @return a dataframe overwritten with the latest sc id.
replace_sc_id_with_latest <- function(data) {
  # Check for required variables
  check_variables_exist(
    data,
    c(
      "sending_location",
      "social_care_id",
      "anon_chi",
      "period",
      "extract_date",
      "consistent_quality"
    )
  )

  # select variables we need
  filter_data <- data %>%
    dplyr::select(
      "sending_location",
      "social_care_id",
      "anon_chi",
      "period",
      "extract_date",
      "consistent_quality"
    ) %>%
    dplyr::filter(!(is.na(.data$anon_chi)))

  change_sc_id <- filter_data %>%
    # OLD method:
    #   Sort (by sending_location, chi and period) for unique chi/sending location
    #   So, it could be multiple CHIs to multiple SCIDs.
    # New method:
    #   Principal:
    #   1. one SCID to one CHI.
    #      Achieved already in process_lookup_sc_demographics().
    #      `process_lookup_sc_demographics()` achieves one CHI to one (sending_location * social_care_id),
    #      but allows one CHI to multiple SCID if from different sending_location.
    #   2. one CHI to one SCID.
    #      Sort by chi only, so one CHI to one SCID no matter sending_location.
    dplyr::arrange(
      # .data$sending_location,
      .data$anon_chi,
      dplyr::desc(.data$period),
      dplyr::desc(.data$extract_date),
      dplyr::desc(.data$consistent_quality)
    ) %>%
    # Find the latest sc_id for each chi/sending location by keeping latest period
    dplyr::distinct(.data$anon_chi, .keep_all = TRUE) %>%
    # Rename for latest sc id
    dplyr::rename(latest_sc_id = "social_care_id") %>%
    # drop period for matching
    dplyr::select(-"period")

  return_data <- change_sc_id %>%
    # Match back onto data
    dplyr::right_join(data,
      by = c("anon_chi"),
      suffix = c("", "_old"),
      multiple = "all"
    ) %>%
    # Overwrite sc id with the latest
    dplyr::mutate(
      social_care_id = dplyr::if_else(
        !is.na(.data$anon_chi) & .data$social_care_id != .data$latest_sc_id,
        .data$latest_sc_id,
        .data$social_care_id
      )
    ) %>%
    dplyr::filter(!is.na(.data$period)) %>%
    dplyr::select(-tidyselect::ends_with("_old"))

  return(return_data)
}
