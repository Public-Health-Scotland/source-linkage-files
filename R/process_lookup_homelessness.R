#' create homelessness lookup
#' @description reads in homelessness extract to create flags
#'
#' @param year The year to process, in FY format.
#' @return the final data as a [tibble][tibble::tibble-package].
#' @export
#' @family process extracts
#'
create_homelessness_lookup <- function(
    year,
    homelessness_data = read_file(get_source_extract_path(year, "Homelessness"))) {
  homelessness_lookup <- homelessness_data %>%
    dplyr::distinct(.data$chi, .data$record_keydate1, .data$record_keydate2) %>%
    tidyr::drop_na(.data$chi) %>%
    dplyr::mutate(hl1_in_fy = 1L)

  return(homelessness_lookup)
}


#' add homelessness flag episode
#' @description add homelessness in FY flag to episode/individual file
#'
#' @param data The extract to process
#' @param year The year to process, in FY format.
#'
#' @return the final data as a [tibble][tibble::tibble-package]
#' @export
add_homelessness_flag <- function(data, year,
                                  lookup = create_homelessness_lookup(year)) {
  ## need to decide which recids this relates to
  data <- data %>%
    dplyr::left_join(
      lookup %>%
        dplyr::distinct(.data$chi, .data$hl1_in_fy),
      by = "chi",
      relationship = "many-to-one"
    ) %>%
    dplyr::mutate(hl1_in_fy = tidyr::replace_na(.data$hl1_in_fy, 0L))

  return(data)
}


#' add homelessness date flags episode
#' @description flags episodes with homelessness applications in 6 months before, 6 months after, or during episode
#'
#' @param data The extract to process
#' @param year The year to process, in FY format.
#'
#' @return the final data as a [tibble][tibble::tibble-package].
#' @export
add_homelessness_date_flags <- function(data, year, lookup = create_homelessness_lookup(year)) {
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
    dplyr::distinct(.data$chi, .data$hl1_in_fy, .data$six_months_pre_app, .data$six_months_post_app, .data$application_date, .data$end_date)


  homeless_flag <- data %>%
    dplyr::select(.data$chi, .data$record_keydate1, .data$record_keydate2, .data$recid) %>%
    dplyr::filter(.data$recid %in% c("00B", "01B", "GLS", "DD", "02B", "04B", "AE2", "OoH", "DN", "CMH", "NRS")) %>%
    dplyr::distinct() %>%
    dplyr::left_join(
      lookup,
      by = "chi", relationship = "many-to-many"
    ) %>%
    dplyr::filter(.data$hl1_in_fy == 1) %>%
    dplyr::mutate(hl1_6before_ep = ifelse((.data$end_date <= .data$record_keydate2) &
      (.data$record_keydate1 <= .data$six_months_post_app), 1, 0)) %>%
    dplyr::mutate(hl1_6after_ep = ifelse((.data$six_months_pre_app <= .data$record_keydate2) &
      (.data$record_keydate1 <= .data$application_date), 1, 0)) %>%
    dplyr::mutate(hl1_during_ep = ifelse((.data$application_date <= .data$record_keydate2) &
      (.data$record_keydate1 <= .data$end_date), 1, 0)) %>%
    dplyr::group_by(.data$chi, .data$recid, .data$record_keydate1, .data$record_keydate2) %>%
    dplyr::summarise(
      hl1_6before_ep = max(.data$hl1_6before_ep),
      hl1_6after_ep = max(.data$hl1_6after_ep),
      hl1_during_ep = max(.data$hl1_during_ep)
    ) %>%
    dplyr::ungroup()


  data <- data %>%
    dplyr::left_join(
      homeless_flag,
      by = c("chi", "record_keydate1", "record_keydate2", "recid"),
      relationship = "many-to-one"
    )

  return(data)
}
