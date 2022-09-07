#' Run data extracts
#'
#' @description Process and data extracts so they are ready for phase 2 production
#' of the episode file.
#'
#' @param year Year of extract
#'
#' @return A list of data containing processed extracts.
#'
#' @export
#'
run_data_extracts <- function(year) {
  process_extracts <- list(
    "homelessness" = process_extract_homelessness(year, read_extract_homelessness(year)),
    "mental_health" = process_extract_mental_health(year, read_extract_mental_health(year))
  )

  return(process_extracts)
}
