#' Process the GP OoH extract
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
read_extract_gp_ooh <- function(year,
                                diagnosis_path = get_boxi_extract_path(year = year, type = "gp_ooh-d"),
                                outcomes_path = get_boxi_extract_path(year = year, type = "gp_ooh-o"),
                                consultations_path = get_boxi_extract_path(year = year, type = "gp_ooh-c")) {
  log_slf_event(stage = "read", status = "start", type = "gpooh", year = year)

  ooh_extracts <- list(
    "diagnosis" = read_extract_ooh_diagnosis(year, diagnosis_path),
    "outcomes" = read_extract_ooh_outcomes(year, outcomes_path),
    "consultations" = read_extract_ooh_consultations(year, consultations_path)
  )

  log_slf_event(stage = "read", status = "complete", type = "gpooh", year = year)

  return(ooh_extracts)
}
