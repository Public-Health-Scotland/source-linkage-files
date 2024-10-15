#' Match on BOXI NRS death dates to process activity after death flag
#'
#' @description Match on CHI number where available in the episode file, and add date of death from the BOXI NRS lookup.
#' Create new activity after death flag
#'
#' @param data episode files
#' @param year financial year, e.g. '1920'
#' @param deaths_data The death data for the year
#'
#' @return data flagged if activity after death
add_activity_after_death_flag <- function(
    data,
    year,
    deaths_data = read_file(get_combined_slf_deaths_lookup_path()) %>%
      slfhelper::get_chi()) {
  # to skip warnings no visible binding for global variable ‘.’
  . <- NULL

  data <- data %>%
    dplyr::mutate(ep_row_id_death = dplyr::row_number())

  death_joined <- data %>%
    dplyr::select(
      "year",
      "chi",
      "recid",
      "record_keydate1",
      "record_keydate2",
      "death_date",
      "deceased",
      "ep_row_id_death"
    ) %>%
    dplyr::filter(!is.na(.data$chi) & .data$chi != "") %>%
    dplyr::left_join(deaths_data,
      by = "chi",
      suffix = c("", "_refined")
    ) %>%
    dplyr::filter(.data$deceased == TRUE) %>%
    dplyr::distinct()

  flag_data <- death_joined %>%
    dplyr::mutate(
      flag_keydate1 = dplyr::if_else(.data$record_keydate1 > .data$death_date_refined, 1, 0),
      flag_keydate2 = dplyr::if_else(.data$record_keydate2 > .data$death_date_refined, 1, 0),

      # Next flag records with 'ongoing' activity after date of death (available from BOXI) if keydate2 is missing and the death date occurs in
      # in the current or a previous financial year.
      flag_keydate2_missing = dplyr::if_else(((is.na(.data$record_keydate2) |
        .data$record_keydate2 == "") &
        (.data$death_date_refined <= paste0("20", substr(.data$year, 3, 4), "-03-31"))
      ), 1, 0),

      # Also flag records without a death_date in the episode file, but the BOXI death date occurs in the current or a previous financial year.
      flag_deathdate_missing = dplyr::if_else(((is.na(.data$death_date) |
        .data$death_date == "") &
        (.data$death_date_refined <= paste0("20", substr(.data$year, 3, 4), "-03-31"))
      ), 1, 0)
    ) %>%
    # These should be flagged by one of the two lines of code above, but in these cases, we will also fill in the blank death date if appropriate

    # Search all variables beginning with "flag_" for value "1" and create new variable to flag cases where 1 is present
    # Multiplying by 1 changes flag from true/false to 1/0
    dplyr::mutate(activity_after_death = purrr::pmap_dbl(
      dplyr::select(., tidyselect::contains("flag_")),
      ~ any(grepl("^1$", c(...)),
        na.rm = TRUE
      ) * 1
    )) %>%
    # Fill in date of death if missing in the episode file but available in BOXI lookup, due to historic dates of death not being carried
    # over from previous financial years
    dplyr::filter(.data$activity_after_death == 1) %>%
    # Remove temporary flag variables used to create activity after death flag and fill in missing death_date
    dplyr::select(
      year,
      chi,
      recid,
      record_keydate1,
      record_keydate2,
      activity_after_death,
      death_date_refined,
      ep_row_id_death
    ) %>%
    dplyr::distinct()

  # Match activity after death flag back to episode file
  final_data <- data %>%
    dplyr::left_join(
      flag_data,
      # this join_by is now 100% accurate.
      by = c(
        "year",
        "chi",
        "recid",
        "record_keydate1",
        "record_keydate2",
        "ep_row_id_death"
      ),
      na_matches = "never"
    ) %>%
    dplyr::mutate(death_date = lubridate::as_date(ifelse(
      is.na(death_date) & !(is.na(death_date_refined)),
      death_date_refined, death_date
    ))) %>%
    dplyr::select(-death_date_refined, -ep_row_id_death) %>%
    dplyr::distinct()

  cli::cli_alert_info("Add activity after death flag function finished at {Sys.time()}")

  return(final_data)
}
