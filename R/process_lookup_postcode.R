#' Process the SLF postcode lookup
#'
#' @description This will read and process the
#' postcode lookup, it will return the final data
#' and (optionally) write it to disk.
#'
#' @param simd_path Path to SIMD lookup.
#' @param locality_path Path to locality lookup.
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
  spd_file <- read_file(spd_path) %>%
    dplyr::select(
      "pc7",
      #tidyselect::matches("datazone\\d{4}$"),
      # Include datazone2011 - phase out proposed end of 25/26
      "datazone2011",
      # New datazone - included start of25/26
      "datazone2022",
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
  simd_file <- read_file(simd_path) %>%
    dplyr::select(
      "pc7",
      tidyselect::matches("simd\\d{4}.?.?_rank"),
      tidyselect::matches("simd\\d{4}.?.?_sc_decile"),
      tidyselect::matches("simd\\d{4}.?.?_sc_quintile"),
      tidyselect::matches("simd\\d{4}.?.?_hb\\d{4}_decile"),
      tidyselect::matches("simd\\d{4}.?.?_hb\\d{4}_quintile"),
      tidyselect::matches("simd\\d{4}.?.?_hscp\\d{4}_decile"),
      tidyselect::matches("simd\\d{4}.?.?_hscp\\d{4}_quintile")
    )

  # locality
  locality_file <- read_file(locality_path) %>%
    dplyr::select(
      locality = "hscp_locality",
      tidyselect::matches("datazone\\d{4}$")
    ) %>%
    dplyr::mutate(
      locality = tidyr::replace_na(.data$locality, "No Locality Information")
    )


  # Join data together  -----------------------------------------------------
  data <- dplyr::left_join(spd_file, simd_file, by = "pc7") %>%
    dplyr::rename(postcode = "pc7") %>%
    dplyr::left_join(locality_file, by = "datazone2011")


  # Finalise output -----------------------------------------------------

  slf_pc_lookup <- data %>%
    dplyr::select(
      "postcode",
      "lca",
      "locality",
      # tidyselect::matches("datazone\\d{4}$")[1L],
      "datazone2011",
      # New datazone - included start of25/26
      "datazone2022",
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

  if (write_to_disk) {
    write_file(
      slf_pc_lookup,
      get_slf_postcode_path(check_mode = "write")
    )
  }

  return(slf_pc_lookup)
}
