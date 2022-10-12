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
run_data_extracts <- function(year, write_to_disk = FALSE) {
  # process_extracts <- list(
  # "homelessness" = process_extract_homelessness(year, read_extract_homelessness(year), write_to_disk = write_to_disk),
  # "mental_health" = process_extract_mental_health(year, read_extract_mental_health(year), write_to_disk = write_to_disk),
  # "maternity" = process_extract_maternity(year, read_extract_maternity(year), write_to_disk = write_to_disk),
  # "ae" = process_extract_ae(year, read_extract_ae(year), write_to_disk = write_to_disk),
  # "acute" = process_extract_acute(year, read_extract_acute(year), write_to_disk = write_to_disk),
  # "outpatients" = process_extract_outpatients(year, read_extract_outpatients(year), write_to_disk = write_to_disk),
  # "nrs_deaths" = process_extract_nrs_deaths(year, read_extract_nrs_deaths(year), write_to_disk = write_to_disk),
  # "cmh" = process_extract_cmh(year, read_extract_cmh(year), write_to_disk = write_to_disk),
  # "district_nursing" = process_extract_district_nursing(year, read_extract_district_nursing(year), write_to_disk = write_to_disk),
  # "pis" = process_extract_pis(year, read_extract_pis(year), write_to_disk = write_to_disk),
  # "dd" = process_extract_delayed_discharges(year, read_extract_delayed_discharges(year), write_to_disk = write_to_disk)
  # )

  process_extracts <- list(
    "acute" = process_extract_acute(year, read_extract_acute(year), write_to_disk = write_to_disk),
    "ae" = process_extract_ae(year, read_extract_ae(year), write_to_disk = write_to_disk),
    "mental_health" = process_extract_mental_health(year, read_extract_mental_health(year), write_to_disk = write_to_disk),
    "maternity" = process_extract_maternity(year, read_extract_maternity(year), write_to_disk = write_to_disk),
    "nrs_deaths" = process_extract_nrs_deaths(year, read_extract_nrs_deaths(year), write_to_disk = write_to_disk),
    "outpatients" = process_extract_outpatients(year, read_extract_outpatients(year), write_to_disk = write_to_disk),
    "pis" = process_extract_prescribing(year, read_extract_prescribing(year), write_to_disk = write_to_disk),
    "ltc" = process_lookup_ltc(read_lookup_ltc(),year,  write_to_disk = write_to_disk)
    # "ooh" = process_extract_ooh(year, read_extract_ooh(year), write_to_disk = write_to_disk)
  )

  if (year > 1516 & year < 2021) {
    process_extracts <- append(
      process_extracts,
      list(
        "district_nursing" = process_extract_district_nursing(year, read_extract_district_nursing(year), write_to_disk = write_to_disk)
      )
    )
  }

  if (year > 1617 & year < 2021) {
    process_extracts <- append(
      process_extracts,
      list(
        "cmh" = process_extract_cmh(year, read_extract_cmh(year), write_to_disk = write_to_disk)
      )
    )
  }

  if (year > 1617) {
    process_extracts <- append(
      process_extracts,
      list(
        "homelessness" = process_extract_homelessness(year, read_extract_homelessness(year)),
        "dd" = process_extract_delayed_discharges(year, read_extract_delayed_discharges(year), write_to_disk = write_to_disk)
      )
    )
  }

  # Run year specific social care data
  #  if (year > 2017) {
  #   process_extracts <- append(
  #    process_extracts,
  #   list(
  #    "Alarms telecare" = process_extract_alarms_telecare(year, read_extract_alarms_telecare(year)),
  #   "CH" = process_extract_care_homes(year, read_extract_care_homes(year)),
  #  "HC" = process_extract_home_care(year, read_extract_home_care(year)),
  # "SDS" = process_extract_sds(year, read_extract_sds(year))
  # )
  # )
  # }

  return(process_extracts)
}
