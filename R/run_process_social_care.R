#' Run Social Care data
#'
#' @description Process and social care data so they are ready for processing
#' social care extracts
#' @param sc_demographics The demographic file. Set to NULL for passing through
#' a data list
#' @param write_to_disk (optional) Should the data be written to disk default is
#' `TRUE` i.e. write the data to disk.
#'
#' @return A list of data containing processed extracts.
#'
#' @export
#'
run_process_social_care <- function(sc_demographics = NULL, write_to_disk = FALSE) {
  process_social_care <- list(
    "home_care" = process_sc_all_home_care(read_sc_all_home_care(),
      sc_demographics = sc_demographics,
      write_to_disk = write_to_disk
    ),
    "alarms_telecare" = process_sc_all_alarms_telecare(read_sc_all_alarms_telecare(),
      sc_demographics = sc_demographics,
      write_to_disk = write_to_disk
    ),
    "sds" = process_sc_all_sds(read_sc_all_sds(),
      sc_demographics = sc_demographics,
      write_to_disk = write_to_disk
      # "care_home" = process_sc_all_care_home(write_to_disk = write_to_disk),
    )
  )

  return(process_social_care)
}
