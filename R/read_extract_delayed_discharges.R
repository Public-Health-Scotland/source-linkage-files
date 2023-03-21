#' Read Delayed Discharges extract
#'
#' @param file_path Path to DD extract
#'
#' @return a [tibble][tibble::tibble-package].
#' @export
#'
read_extract_delayed_discharges <- function(file_path = get_dd_path()) {
  extract_delayed_discharges <- readr::read_rds(file_path) %>%
    janitor::clean_names() %>%
    # rename variables
    dplyr::rename(
      keydate1_dateformat = .data$rdd,
      keydate2_dateformat = .data$delay_end_date
    )

  return(extract_delayed_discharges)
}
