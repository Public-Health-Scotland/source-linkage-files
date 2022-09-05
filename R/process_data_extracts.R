#' Read data extracts
#'
#' @param year Year of extract
#'
#' @return csv data files of extracts
#' @export
#'
process_data_extracts <- function(year) {

  # Add extracts to this list for processing
  process_extracts <- list(
    process_extract_homelessness(year, read_extract_homelessness(year)),
    process_extract_mental_health(year, read_extract_mental_health(year))
  )

  return(process_extracts)

}
