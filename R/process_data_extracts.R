#' Read data extracts
#'
#' @param year Year of extract
#'
#' @return csv data files of extracts
#' @export
#'
process_data_extracts <- function(year) {
  process_extracts <- list(
    "homelessness" = process_extract_homelessness(year, read_extract_homelessness(year)),
    "mental_health" = process_extract_mental_health(year, read_extract_mental_health(year))
  )

  return(process_extracts)
}
