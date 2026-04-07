#' Read the GP OoH extract
#'
#' @description This will read and process the
#' GP OoH extract, it will return the final data
#' and (optionally) write it to disk.
#'
#' @param year The year to process, in FY format.
#' @param diagnosis_path Path to diagnosis BOXI extract location.
#' @param outcomes_path Path to outcomes BOXI extract location.
#' @param consultations_path Path to consultations BOXI extract location.
#'
#' @return the final data as a [tibble][tibble::tibble-package].
#' @export
#' @family process extracts
read_extract_gp_ooh <- function(
    year,
    denodo_connect = get_denodo_connection(BYOC_MODE = BYOC_MODE),
    diagnosis_path = get_boxi_extract_path(year = year, type = "gp_ooh-d", BYOC_MODE = BYOC_MODE),
    outcomes_path = get_boxi_extract_path(year = year, type = "gp_ooh-o", BYOC_MODE = BYOC_MODE),
    consultations_path = get_boxi_extract_path(year = year, type = "gp_ooh-c", BYOC_MODE = BYOC_MODE),
    BYOC_MODE
) {
  log_slf_event(stage = "read", status = "start", type = "gpooh", year = year)

  on.exit(try(DBI::dbDisconnect(denodo_connect), silent = TRUE), add = TRUE)

  ooh_extracts <- list(
    "diagnosis"     = read_extract_ooh_diagnosis(year = year,
                                                 denodo_connect = denodo_connect,
                                                 file_path = diagnosis_path,
                                                 BYOC_MODE = BYOC_MODE),

    "outcomes"      = read_extract_ooh_outcomes(year = year,
                                                denodo_connect = denodo_connect,
                                                file_path = outcomes_path,
                                                BYOC_MODE = BYOC_MODE),

    "consultations" = read_extract_ooh_consultations(year = year,
                                                     denodo_connect = denodo_connect,
                                                     file_path = consultations_path,
                                                     BYOC_MODE = BYOC_MODE)
  )

  log_slf_event(stage = "read", status = "complete", type = "gpooh", year = year)

  return(ooh_extracts)
}
