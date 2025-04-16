#' Process the refined death data
#'
#' @description This will process
#' year-specific BOXI NRS death file (written to disk), and
#' combine them together to get all years NRS file (Not written to disk).
#' Then join all NRS deaths with IT CHI death data
#' to get an all-year refined death file (written to disk).
#'
#' @param it_chi_deaths it chi death data
#' @param write_to_disk write the result to disk or not.
#'
#' @return refined_death The processed lookup of deaths combining NRS and IT_CHI.
#' @export
#' @family process extracts
process_refined_death <- function(
    it_chi_deaths = read_file(get_slf_chi_deaths_path()),
    write_to_disk = TRUE) {
  years_list <- years_to_run()

  nrs_all_years <- lapply(years_list, (\(year) {
    read_extract_nrs_deaths(
      year,
      get_boxi_extract_path(year, type = "deaths")
    ) %>%
      process_extract_nrs_deaths(year,
        write_to_disk = write_to_disk
      )
  })) %>%
    data.table::rbindlist()

  it_chi_deaths <- it_chi_deaths %>%
    dplyr::select(c(
      "anon_chi",
      "death_date_chi"
    )) %>%
    dplyr::arrange(.data$anon_chi, .keep_all = TRUE)

  refined_death <- nrs_all_years %>%
    dplyr::arrange(.data$anon_chi, .keep_all = TRUE) %>%
    dplyr::full_join(it_chi_deaths, by = "anon_chi") %>%
    # use the BOXI NRS death date by default, but if it's missing, use the chi death date.
    dplyr::mutate(death_date = dplyr::if_else(
      is.na(.data$record_keydate1),
      .data$death_date_chi,
      .data$record_keydate1
    )) %>%
    dplyr::select("anon_chi", "death_date") %>%
    # add fy when death happened
    dplyr::mutate(
      fy = phsmethods::extract_fin_year(.data$death_date),
      fy = as.character(paste0(substr(fy, 3, 4), substr(fy, 6, 7)))
    ) %>%
    # no need to keep NA
    dplyr::filter(!is.na(.data$anon_chi)) %>%
    dplyr::group_by(.data$anon_chi) %>%
    dplyr::arrange(.data$death_date) %>%
    dplyr::distinct(.data$anon_chi, .keep_all = TRUE) %>%
    dplyr::ungroup()

  if (write_to_disk) {
    write_file(
      refined_death,
      get_combined_slf_deaths_lookup_path(create = TRUE),
      group_id = 3206 # hscdiip owner
    )
  }

  return(refined_death)
}
