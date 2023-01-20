#' Read Delayed Discharges extract
#'
#' @param file_path Path to DD extract
#'
#' @return zsav/rds data file for Delayed discharges
#' @export
#'
read_extract_delayed_discharges <- function(file_path = get_dd_path(ext = "zsav")) {

  extract_delayed_discharges <- haven::read_sav(file_path) %>%
    janitor::clean_names() %>%
    # rename variables
    dplyr::rename(
      keydate1_dateformat = .data$rdd,
      keydate2_dateformat = .data$delay_end_date
    )

  return(extract_delayed_discharges)
}
