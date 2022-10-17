#' Run data lookups
#'
#' @description Process and data lookups so they are ready for phase 3 production
#' of the episode file.
#'
#' @param year Year of extract
#'
#' @return A list of data containing processed extracts.
#'
#' @export
#'
run_data_lookups <- function(year, write_to_disk = FALSE) {
  process_lookups <- list(
    ## SLF lookups
    "postcode" = process_lookup_postcode(write_to_disk = write_to_disk),
    "gpprac" = process_lookup_gpprac(write_to_disk = write_to_disk),
    "chi_deaths" = process_lookup_chi_deaths(read_lookup_chi_deaths(), write_to_disk = write_to_disk),
    ## Social Care lookups
    "sc_demographics" = process_lookup_sc_demographics(read_lookup_sc_demographics(), write_to_disk = write_to_disk),
    ## Cost lookups
    "costs_gp_ooh" = process_costs_gp_ooh(read_costs_gp_ooh(), write_to_disk = write_to_disk),
    "costs_district_nursing" = process_costs_district_nursing(read_costs_district_nursing(), write_to_disk = write_to_disk),
    "costs_care_home" = process_costs_care_home(read_costs_care_home(), write_to_disk = write_to_disk),
    "costs_home_care" = process_costs_home_care(read_costs_home_care(), write_to_disk = write_to_disk)
  )

  return(process_lookups)
}
