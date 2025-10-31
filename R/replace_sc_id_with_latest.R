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
                      multiple = "all") %>%
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



select_linking_id <- function(data) {
  data %>% dplyr::mutate(linking_id = dplyr::if_else(
    is.na(.data$anon_chi),
    paste0("SCID", .data$sending_location, "-",.data$social_care_id),
    .data$anon_chi
  ))
}

add_fy_qtr_from_period = function(data){
  data %>%
    # create financial_year and financial_quarter variables for sorting
    dplyr::mutate(
      financial_year = as.numeric(stringr::str_sub(.data$period, 1, 4)),
      financial_quarter = stringr::str_sub(.data$period, 6, 6)
    ) %>%
    # set financial quarter to 5 when there is only an annual submission -
    # for ordering periods with annual submission last
    dplyr::mutate(
      financial_quarter = dplyr::if_else(
        is.na(.data$financial_quarter) |
          .data$financial_quarter == "",
        "5",
        .data$financial_quarter
      )
    )
}

which_fy <- function(date, format = c("year", "fyear")) {
  year <- as.numeric(format(date, "%Y"))
  month <- as.numeric(format(date, "%m"))

  start_year <- ifelse(month<4, year - 1, year)
  end_year <- start_year + 1
  if (format == "year") {
    return(start_year)
  } else{
    return(paste0(substr(start_year, 3, 4), substr(end_year, 3, 4)))
  }
}
