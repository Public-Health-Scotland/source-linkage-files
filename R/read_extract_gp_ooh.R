#' Process the GP OoH extract
#'
#' @description This will read and process the
#' GP OoH extract, it will return the final data
#' but also write this out as a zsav and rds.
#'
#' @param year The year to process, in FY format.
#'
#' @return the final data as a [tibble][tibble::tibble-package].
#' @export
#' @family process extracts
read_extract_gp_ooh <- function(year,
                                diagnosis_path = get_boxi_extract_path(year = year, type = "GP_OoH-d"),
                                outcomes_path = get_boxi_extract_path(year = year, type = "GP_OoH-o"),
                                consultations_path = get_boxi_extract_path(year = year, type = "GP_OoH-c")) {
  ooh_extracts <- list(
    "diagnosis" = read_extract_ooh_diagnosis(year, diagnosis_path),
    "outcomes" = read_extract_ooh_outcomes(year, outcomes_path),
    "consultations" = read_extract_ooh_consultations(year, consultations_path)
  )

  return(ooh_extracts)
}
