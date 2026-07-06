#' Read BOXI extract GP OoH CUP from Denodo
#'
#' @param denodo_connect denodo connection
#' @param year financial year
#'
#' @export
read_extract_gp_ooh_cup <- function(year,
                                    denodo_connect = get_denodo_connection(BYOC_MODE = BYOC_MODE)) {
  c_year_cup <- convert_fyyear_to_year(check_year_format(year))

  # Disconnect from Denodo
  on.exit(try(DBI::dbDisconnect(denodo_connect), silent = TRUE),
    add = TRUE
  )

  gp_ooh_cup <- dplyr::tbl(
    denodo_connect,
    dbplyr::in_schema("sdl", "sdl_gp_ooh_cup_source")
  ) %>%
    dplyr::filter(gp_ooh_sc_start_financial_year == c_year_cup) %>%
    dplyr::select(
      record_keydate1 = "gp_ooh_consultation_start_date",
      keytime1 = "gp_ooh_consultation_start_time",
      ooh_case_id = "guid",
      cup_marker = "cup_marker",
      cup_pathway = "cup_pathway_name"
    ) %>%
    dplyr::collect() %>%
    dplyr::distinct(record_keydate1, keytime1, ooh_case_id, .keep_all = TRUE) %>%
    # TODO: remove modifying time format after UAT
    dplyr::mutate(keytime1 = hms::as_hms(as.difftime(keytime1, format = "%M:%S")))


  return(gp_ooh_cup)
}
