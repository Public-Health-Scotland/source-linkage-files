#' Process cross year tests
#'
#' @description Process high level tests (e.g the number of records in each recid)
#' across years.
#'
#' @param year Year of the file to be read, you can specify multiple years
#'  which will then be returned as one file. See SLFhelper for more info.
#'
#' @return a tibble with a test summary across years
#' @export
#'
process_tests_cross_year <- function(year) {
  ep_file <- read_dev_slf_file(year,
    type = "episode",
    col_select = c("year", "recid", "anon_chi", "record_keydate1", "record_keydate2")
  )

  total_test <- ep_file %>%
    dplyr::group_by(.data$year, .data$recid) %>%
    dplyr::mutate(
      n_records = 1L
    ) %>%
    dplyr::summarise(
      n = sum(n_records)
    ) %>%
    dplyr::mutate(
      fy_qtr = "total"
    )

  qtr_test <- ep_file %>%
    dplyr::mutate(
      fy_qtr = dplyr::if_else(recid != "PIS", lubridate::quarter(record_keydate1, fiscal_start = 4), NA)
    ) %>%
    dplyr::group_by(.data$year, .data$recid, .data$fy_qtr) %>%
    dplyr::mutate(
      n_records = 1L
    ) %>%
    dplyr::summarise(
      n = sum(n_records)
    ) %>%
    dplyr::mutate(
      fy_qtr = as.character(fy_qtr)
    )

  join_tests <- dplyr::bind_rows(total_test, qtr_test) %>%
    dplyr::arrange(year, recid, fy_qtr)

  pivot_tests <- join_tests %>%
    tidyr::pivot_wider(
      names_from = c("year", "fy_qtr"),
      names_glue = "{year}_qtr_{fy_qtr}",
      values_from = "n"
    ) %>%
    dplyr::select(-tidyselect::ends_with("NA"))

  return(pivot_tests)
}
