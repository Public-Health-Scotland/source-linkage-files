# It would probably be simplest to create a lookup from the Homelessness data of one row per CHI +
#   start dates of all applications. This can then be matched to episode and individual to easily create the hl1_in_fy flag(s)
# (if someone is in the lookup -> 1, otherwise -> 0). For the episode file, it is slightly more complicated to create the other flags,
# either matching on all the data by CHI and then doing some comparison of dates (as in SPSS),
# or using some of the fancy new joins (dplyr 1.1.0 joins) and doing it that way.
#
#


# data <- slfhelper::read_slf_episode("1718", c("anon_chi", "record_keydate1", "record_keydate2", "recid"))

# year <- "1718"


#' create homelessness lookup
#' @description reads in homelessness extract and selects CHIs and flags them as homeless in FY
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
#' @return the final data as a [tibble][tibble::tibble-package].
#' @export
add_homelessness_flag <- function(data, year, lookup = create_homelessness_lookup(year)) { 

  ## need to decide which recids this relates to
  data <- data %>%
    dplyr::left_join(
      lookup %>%
        dplyr::distinct(anon_chi, hl1_in_fy),
      by = "chi",
      relationship = "many-to-one"
    ) %>%
    dplyr::mutate(hl1_in_fy = tidyr::replace_na(hl1_in_fy, 0L))

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
add_homelessness_date_flags_episode <- function(data, year, lookup = create_homelessness_lookup(year)) {
  lookup <- lookup %>%
    dplyr::filter(!(is.na(record_keydate2))) %>%
    dplyr::rename(
      application_date = record_keydate1,
      end_date = record_keydate2
    ) %>%
    dplyr::mutate(
      six_months_pre_app = application_date - lubridate::days(180),
      six_months_post_app = end_date + lubridate::days(180)
    ) %>%
    dplyr::distinct(anon_chi, hl1_in_fy, six_months_pre_app, six_months_post_app, application_date, end_date)


  homeless_flag <- data %>%
    dplyr::select(anon_chi, record_keydate1, record_keydate2, recid) %>%
    dplyr::filter(recid %in% c("00B", "01B", "GLS", "DD", "02B", "04B", "AE2", "OoH", "DN", "CMH", "NRS")) %>%
    dplyr::distinct() %>%
    dplyr::left_join(
      lookup,
      by = "anon_chi", relationship = "many-to-many"
    ) %>%
    dplyr::filter(hl1_in_fy == 1) %>%
    dplyr::mutate(hl1_6before_ep = ifelse((end_date <= record_keydate2) &
      (record_keydate1 <= six_months_post_app), 1, 0)) %>%
    dplyr::mutate(hl1_6after_ep = ifelse((six_months_pre_app <= record_keydate2) &
      (record_keydate1 <= application_date), 1, 0)) %>%
    dplyr::mutate(hl1_during_ep = ifelse((application_date <= record_keydate2) &
      (record_keydate1 <= end_date), 1, 0)) %>%
    dplyr::group_by(anon_chi, recid, record_keydate1, record_keydate2) %>%
    dplyr::summarise(
      hl1_6before_ep = max(hl1_6before_ep),
      hl1_6after_ep = max(hl1_6after_ep),
      hl1_during_ep = max(hl1_during_ep)
    ) %>%
    dplyr::ungroup()


  data <- data %>%
    dplyr::left_join(homeless_flag,
      by = c("anon_chi", "record_keydate1", "record_keydate2", "recid"), relationship = "many-to-one"
    ) # add HL1inFY back in

  return(data)
}
