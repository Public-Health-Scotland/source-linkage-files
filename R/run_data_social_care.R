#' Run Social Care data
#'
#' @description Process and social care data so they are ready for processing
#' social care extracts
#'
#' @return A list of data containing processed extracts.
#'
#' @export
#'
run_data_social_care <- function(sc_demographics = [data list], write_to_disk = FALSE) {
  process_social_care <- list(
    #"care_home" = process_sc_all_care_home(write_to_disk = write_to_disk),
    "home_care" = process_sc_all_home_care(read_sc_all_home_care(),
                                           sc_demographics = sc_demographics,
                                           write_to_disk = write_to_disk),
    "alarms_telecare" = process_sc_all_alarms_telecare(read_sc_all_alarms_telecare(),
                                                       sc_demographics = sc_demographics,
                                                       write_to_disk = write_to_disk),
    #"sds" = process_sc_all_sds(write_to_disk = write_to_disk)
  )

  return(process_lookups)
}
