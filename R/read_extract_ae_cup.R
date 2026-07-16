#' Read BOXI extracts AE CUP
#'
#' @inherit read_extract_ae
#'
#' @export
read_extract_ae_cup <- function(
  year,
  denodo_connect = get_denodo_connection(BYOC_MODE = BYOC_MODE),
  BYOC_MODE
) {
  log_slf_event(stage = "read", status = "start", type = "ae_cup", year = year)

  year <- check_year_format(year, format = "fyyear")
  c_year <- convert_fyyear_to_year(year)

  # Specify years available for running
  if (!check_year_valid(year, type = "ae")) {
    return(tibble::tibble())
  }

  on.exit(try(DBI::dbDisconnect(denodo_connect), silent = TRUE), add = TRUE)

  ae_cup_file <- dplyr::tbl(
    denodo_connect,
    dbplyr::in_schema("sdl", "sdl_ae_ucd_cup_source")
  ) %>%
    dplyr::filter(
      ed_arrival_financial_year == c_year,
      (significant_facility_code == "32" | is.na(significant_facility_code))
    ) %>%
    dplyr::select(
      record_keydate1 = "ed_arrival_date",
      keytime1 = "ed_arrival_time",
      record_keydate2 = "ed_discharge_date",
      keytime2 = "ed_discharge_time",
      case_ref_number = "ed_case_reference_number",
      cup_marker = "cup_marker",
      cup_pathway = "cup_pathway_name"
    ) %>%
    dplyr::collect() %>%
    # TODO: remove after UAT
    dplyr::mutate(
      keytime1 = hms::as_hms(paste0(.data$keytime1, ":00")),
      keytime2 = hms::as_hms(paste0(.data$keytime2, ":00"))
    )

  log_slf_event(stage = "read", status = "complete", type = "ae_cup", year = year)

  return(ae_cup_file)
}
