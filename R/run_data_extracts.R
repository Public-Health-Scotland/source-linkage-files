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
    "homelessness" = process_extract_homelessness(year, read_extract_homelessness(year), write_to_disk = FALSE),
    "mental_health" = process_extract_mental_health(year, read_extract_mental_health(year), write_to_disk = FALSE),
    "maternity" = process_extract_maternity(year, read_extract_maternity(year), write_to_disk = FALSE),
    "ae" = process_extract_ae(year, read_extract_ae(year), write_to_disk = FALSE),
    "acute" = process_extract_acute(year, read_extract_acute(year), write_to_disk = FALSE),
    "outpatients" = process_extract_outpatients(year, read_extract_outpatients(year), write_to_disk = FALSE)
  )


  # process_extracts <- list(
  #   "mental_health" = process_extract_mental_health(year, read_extract_mental_health(year)),
  #   "maternity" = process_extract_maternity(year, read_extract_maternity(year))
  #   #"a&e" = process_extract_ae(year, read_extract_ae(year))
  # )

  #  if (year > 2016) {
  #    process_extracts <- append(process_extracts,
  #                               list(
  #                                 "homelessness" = process_extract_homelessness(year, read_extract_homelessness(year)),
  #                                 DD
  #                                ))

  # }

  # if (year > 2017) {
  #   process_extracts <- append(process_extracts,
  #                              list(
  #                                "Alarms telecare" = process_extract_homelessness(year, read_extract_homelessness(year)),
  #                                "HC",
  #                                "CH",
  #                                "SDS"
  #                              ))
  #
  # }

  return(process_extracts)
}
