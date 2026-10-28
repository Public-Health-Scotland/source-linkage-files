#' Read the GP OoH extract
#'
#' @description This will read and process the
#' GP OoH extract, it will return the final data
#' and (optionally) write it to disk.
#'
#' @param year The year to process, in FY format.
#' @param decodo_connect denodo_connection
#' @param diagnosis_path Path to diagnosis BOXI extract location.
#' @param outcomes_path Path to outcomes BOXI extract location.
#' @param consultations_path Path to consultations BOXI extract location.
#'
#' @return the final data as a [tibble][tibble::tibble-package].
#' @export
#' @family process extracts
read_extract_gp_ooh <- function(
  year,
  # A central denodo_connect could be disconnected by read_extract_ooh_diagnosis
  # So read_extract_ooh_outcomes cannot use that denodo_connect which is disconnected
  # Hence, create denodo_connect in each sub-function.
  denodo_connect = NULL,
  BYOC_MODE
) {
  log_slf_event(stage = "read", status = "start", type = "gpooh", year = year)

  ooh_extracts <- list(
    "diagnosis" = read_extract_ooh_diagnosis(
      year = year,
      denodo_connect = get_denodo_connection(BYOC_MODE = BYOC_MODE),
      BYOC_MODE = BYOC_MODE
    ),
    "outcomes" = read_extract_ooh_outcomes(
      year = year,
      denodo_connect = get_denodo_connection(BYOC_MODE = BYOC_MODE),
      BYOC_MODE = BYOC_MODE
    ),
    "consultations" = read_extract_ooh_consultations(
      year = year,
      denodo_connect = get_denodo_connection(BYOC_MODE = BYOC_MODE),
      BYOC_MODE = BYOC_MODE
    )
  )

  log_slf_event(stage = "read", status = "complete", type = "gpooh", year = year)

  return(ooh_extracts)
}
