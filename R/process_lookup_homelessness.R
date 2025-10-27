#' Create a homelessness lookup
#' @description Reads in the homelessness extract and creates
#' a lookup at CHI level, with one row per application start
#' and end date for each CHI.
#'
#' @param homelessness_data the processed homelessness data for
#' the financial year (created with [process_extract_homelessness()]).
#' @inheritParams create_episode_file
#'
#' @return the final data as a [tibble][tibble::tibble-package].
#' @export
#' @family process extracts
create_homelessness_lookup <- function(
  year,
  homelessness_data = read_file(get_source_extract_path(year, "homelessness"))
) {
  # Specify years available for running
  if (year <= "1516") {
    return(NULL)
  }
  homelessness_lookup <- homelessness_data %>%
    dplyr::distinct(.data$anon_chi, .data$record_keydate1, .data$record_keydate2) %>%
    tidyr::drop_na(.data$anon_chi) %>%
    dplyr::mutate(hl1_in_fy = 1L)

  cli::cli_alert_info("Create homelessness lookup function finished at {Sys.time()}")

  return(homelessness_lookup)
}


#' Add 'homelessness in FY' flag
#' @description Add a flag to the data indicating if the CHI
#' had a homelessness episode within the financial year.
#'
#' @param data The data to add the flag to - the episode
#' or individual file.
#' @param lookup The homelessness lookup created by [create_homelessness_lookup()]
#' @inheritParams create_episode_file
#'
#' @return the final data as a [tibble][tibble::tibble-package]
#' @export
#' @family episode_file
add_homelessness_flag <- function(data, year,
                                  lookup = create_homelessness_lookup(year)) {
  if (!check_year_valid(year, type = "homelessness")) {
    data <- data
    return(data)
  }

  data <- data %>%
    dplyr::left_join(
      lookup %>%
        dplyr::distinct(.data$anon_chi, .data$hl1_in_fy),
      by = "anon_chi",
      relationship = "many-to-one"
    ) %>%
    dplyr::mutate(hl1_in_fy = tidyr::replace_na(.data$hl1_in_fy, 0L))

  cli::cli_alert_info("Add homelessness flag function finished at {Sys.time()}")

  return(data)
}


#' Add homelessness date flags episode
#'
#' @description Add flags to episodes indicating if they
#' have had at least one active homelessness application in
#' 6 months before, 6 months after, or during an episode.
#'
#' @inheritParams add_homelessness_flag
#'
#' @return the final data as a [tibble][tibble::tibble-package].
#' @export
add_homelessness_date_flags <- function(data, year, lookup = create_homelessness_lookup(year)) {
  if (!check_year_valid(year, type = "homelessness")) {
    data <- data
    return(data)
  }

  lookup <- lookup %>%
    dplyr::filter(!(is.na(.data$record_keydate2))) %>%
    dplyr::rename(
      application_date = .data$record_keydate1,
      end_date = .data$record_keydate2
    ) %>%
    dplyr::mutate(
      six_months_pre_app = .data$application_date - lubridate::days(180),
      six_months_post_app = .data$end_date + lubridate::days(180)
    ) %>%
    dplyr::distinct(.data$anon_chi, .data$hl1_in_fy, .data$six_months_pre_app, .data$six_months_post_app, .data$application_date, .data$end_date)


  homeless_flag <- data %>%
    dplyr::select(.data$anon_chi, .data$record_keydate1, .data$record_keydate2, .data$recid) %>%
    dplyr::filter(.data$recid %in% c("00B", "01B", "GLS", "DD", "02B", "04B", "AE2", "OoH", "DN", "CMH", "NRS")) %>%
    dplyr::distinct() %>%
    dplyr::left_join(
      lookup,
      by = "anon_chi", relationship = "many-to-many"
    ) %>%
    dplyr::filter(.data$hl1_in_fy == 1) %>%
    dplyr::mutate(hl1_6before_ep = ifelse((.data$end_date <= .data$record_keydate2) &
      (.data$record_keydate1 <= .data$six_months_post_app), 1, 0)) %>%
    dplyr::mutate(hl1_6after_ep = ifelse((.data$six_months_pre_app <= .data$record_keydate2) &
      (.data$record_keydate1 <= .data$application_date), 1, 0)) %>%
    dplyr::mutate(hl1_during_ep = ifelse((.data$application_date <= .data$record_keydate2) &
      (.data$record_keydate1 <= .data$end_date), 1, 0)) %>%
    dplyr::group_by(.data$anon_chi, .data$recid, .data$record_keydate1, .data$record_keydate2) %>%
    dplyr::summarise(
      hl1_6before_ep = max(.data$hl1_6before_ep),
      hl1_6after_ep = max(.data$hl1_6after_ep),
      hl1_during_ep = max(.data$hl1_during_ep)
    ) %>%
    dplyr::ungroup()


  data <- data %>%
    dplyr::left_join(
      homeless_flag,
      by = c("anon_chi", "record_keydate1", "record_keydate2", "recid"),
      relationship = "many-to-one"
    ) %>%
    dplyr::mutate(
      hl1_12_months_pre_app = lubridate::rollback(.data$record_keydate1,
        months(-12),
        roll_to_first = TRUE
      ),
      hl1_12_months_post_app = lubridate::add_with_rollback(.data$record_keydate2,
        months(12),
        roll_to_first = TRUE
      )
    )

  cli::cli_alert_info("Add homelessness date flags function finished at {Sys.time()}")

  return(data)
}
