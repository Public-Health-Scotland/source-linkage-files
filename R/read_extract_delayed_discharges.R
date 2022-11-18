#' Read Delayed Discharges extract
#'
#' @return zsav/rds data file for Delayed discharges
#' @export
#'
read_extract_delayed_discharges <- function() {
  extract_delayed_discharges <- haven::read_sav(get_dd_path(ext = "zsav")) %>%
    janitor::clean_names() %>%
    # rename variables
    dplyr::rename(
      keydate1_dateformat = .data$rdd,
      keydate2_dateformat = .data$delay_end_date
    )

  return(extract_delayed_discharges)
}
