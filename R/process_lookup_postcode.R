#' Process the SLF postcode lookup
#'
#' @description This will read and process the
#' postcode lookup, it will return the final data
#' but also write this out as a zsav and rds.
#'
#' @param simd_path Path to SIMD lookup.
#' @param locality_path Path to locality lookup.
#'
#' @param write_to_disk (optional) Should the data be written to disk default is
#' `TRUE` i.e. write the data to disk.
#'
#' @inheritParams process_lookup_gpprac
#'
#' @return the final data as a [tibble][tibble::tibble-package].
#' @export
#' @family process extracts

process_lookup_postcode <- function(spd_path = get_spd_path(),
                                    simd_path = get_simd_path(),
                                    locality_path = get_locality_path(),
                                    write_to_disk = TRUE) {
  # Read lookup files -------------------------------------------------------

  # postcode data
  spd_file <- readr::read_rds(spd_path) %>%
    dplyr::select(
      .data$pc7,
      tidyselect::matches("datazone\\d{4}$"),
      tidyselect::matches("hb\\d{4}$"),
      tidyselect::matches("hscp\\d{4}$"),
      tidyselect::matches("ca\\d{4}$"),
      tidyselect::matches("ur8_\\d{4}$"),
      tidyselect::matches("ur6_\\d{4}$"),
      tidyselect::matches("ur3_\\d{4}$"),
      tidyselect::matches("ur2_\\d{4}$")
    ) %>%
    dplyr::mutate(lca = convert_ca_to_lca(.data$ca2019))

  # simd data
  simd_file <- readr::read_rds(simd_path) %>%
    dplyr::select(
      .data$pc7,
      tidyselect::matches("simd\\d{4}.?.?_rank"),
      tidyselect::matches("simd\\d{4}.?.?_sc_decile"),
      tidyselect::matches("simd\\d{4}.?.?_sc_quintile"),
      tidyselect::matches("simd\\d{4}.?.?_hb\\d{4}_decile"),
      tidyselect::matches("simd\\d{4}.?.?_hb\\d{4}_quintile"),
      tidyselect::matches("simd\\d{4}.?.?_hscp\\d{4}_decile"),
      tidyselect::matches("simd\\d{4}.?.?_hscp\\d{4}_quintile")
    )

  # locality
  locality_file <- readr::read_rds(locality_path) %>%
    dplyr::select(
      locality = .data$hscp_locality,
      tidyselect::matches("datazone\\d{4}$")
    ) %>%
    dplyr::mutate(
      locality = tidyr::replace_na(.data$locality, "No Locality Information")
    )


  # Join data together  -----------------------------------------------------
  data <-
    dplyr::left_join(spd_file, simd_file, by = "pc7") %>%
    dplyr::rename(postcode = "pc7") %>%
    dplyr::left_join(locality_file, by = "datazone2011")


  # Finalise output -----------------------------------------------------

  outfile <-
    data %>%
    dplyr::select(
      .data$postcode,
      .data$lca,
      .data$locality,
      tidyselect::matches("datazone\\d{4}$")[1L],
      tidyselect::matches("hb\\d{4}$(?:20[2-9]\\d)|(?:201[89])$"),
      tidyselect::matches("hscp\\d{4}$(?:20[2-9]\\d)|(?:201[89])$"),
      tidyselect::matches("ca\\d{4}$(?:20[2-9]\\d)|(?:201[89])$"),
      tidyselect::matches("simd\\d{4}.?.?_rank"),
      tidyselect::matches("simd\\d{4}.?.?_sc_decile"),
      tidyselect::matches("simd\\d{4}.?.?_sc_quintile"),
      tidyselect::matches("simd\\d{4}.?.?_hb\\d{4}_decile"),
      tidyselect::matches("simd\\d{4}.?.?_hb\\d{4}_quintile"),
      tidyselect::matches("simd\\d{4}.?.?_hscp\\d{4}_decile"),
      tidyselect::matches("simd\\d{4}.?.?_hscp\\d{4}_quintile"),
      tidyselect::matches("ur8_\\d{4}$"),
      tidyselect::matches("ur6_\\d{4}$"),
      tidyselect::matches("ur3_\\d{4}$"),
      tidyselect::matches("ur2_\\d{4}$")
    )


  # Save out ----------------------------------------------------------------
  if (write_to_disk) {
    outfile %>%
      # Save .rds file
      write_rds(get_slf_postcode_path(check_mode = "write"))
  }

  return(outfile)
}
