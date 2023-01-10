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
read_extract_gp_ooh <- function(year) {
  ooh_extracts <- list(
    "diagnosis" = read_extract_ooh_diagnosis(year),
    "outcomes" = read_extract_ooh_outcomes(year),
    "consultations" = read_extract_ooh_consultations(year)
  )

  return(ooh_extracts)
}
