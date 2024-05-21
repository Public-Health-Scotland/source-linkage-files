#' Read Delayed Discharges extract
#'
#' @param file_path Path to DD extract
#'
#' @return a [tibble][tibble::tibble-package].
#' @export
#'
read_extract_delayed_discharges <- function(file_path = get_dd_path()) {
  extract_delayed_discharges <- read_file(file_path) %>%
    janitor::clean_names() %>%
    dplyr::mutate(
      monthflag = lubridate::my(.data[["monthflag"]]),
      delay_end_reason = as.integer(.data[["delay_end_reason"]])
    ) %>%
    dplyr::select(-.data[["cennum"]]) %>%
    slfhelper::get_chi()

  return(extract_delayed_discharges)
}
