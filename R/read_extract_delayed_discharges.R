#' Read Delayed Discharges extract
#'
#' @param year Year of BOXI extract
#'
#' @return zsav/rds data file for Delayed discharges
#' @export
#'
read_extract_delayed_discharges <- function(year) {
  extract_delayed_discharges <- haven::read_sav(get_dd_path(ext = "zsav")) %>%
    clean_names() %>%
    # rename variables
    rename(
      keydate1_dateformat = rdd,
      keydate2_dateformat = delay_end_date
    )

  return(extract_delayed_discharges)
}
