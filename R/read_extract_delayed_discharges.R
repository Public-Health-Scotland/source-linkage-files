#' Read Delayed Discharges extract
#'
#' @param file_path Path to DD extract
#'
#' @return a [tibble][tibble::tibble-package].
#' @export
#'
read_extract_delayed_discharges <- function(file_path = get_dd_path()) {
  log_slf_event(stage = "read", status = "start", type = "dd", year = year)

  extract_delayed_discharges <- read_file(file_path) %>%
    janitor::clean_names() %>%
    dplyr::mutate(
      monthflag = lubridate::my(.data[["monthflag"]]),
      delay_end_reason = as.integer(.data[["delay_end_reason"]])
    ) %>%
    dplyr::select(-.data[["cennum"]])

  log_slf_event(stage = "read", status = "complete", type = "dd", year = year)

  return(extract_delayed_discharges)
}
