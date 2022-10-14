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
    "sc_client" = process_lookup_sc_client(read_lookup_sc_client(), year, write_to_disk = write_to_disk)
    # "sc_ch_name" = process_lookup_sc_ch_name(year, write_to_disk = write_to_disk)
  )

  return(process_lookups)
}
