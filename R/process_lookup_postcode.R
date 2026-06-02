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
process_lookup_postcode <- function(spd_data = get_spd_data(
                                      denodo_connect = get_denodo_connection(BYOC_MODE = BYOC_MODE),
                                      file_path = get_spd_path(), # TODO: Add this argument to the function in refactor-sc-demographics branch?
                                      BYOC_MODE
                                    ),
                                    simd_data = get_simd_data(
                                      denodo_connect = get_denodo_connection(BYOC_MODE = BYOC_MODE),
                                      file_path = get_simd_path(),
                                      BYOC_MODE
                                    ),
                                    locality_data = get_locality_data(
                                      denodo_connect = get_denodo_connection(BYOC_MODE = BYOC_MODE),
                                      file_path = get_locality_path(),
                                      BYOC_MODE
                                    ),
                                    BYOC_MODE = FALSE,
                                    run_id = NA,
                                    run_date_time = NA,
                                    write_to_disk = TRUE) {
  # TODO: Check arguments - do get_spd_data, simd_data and get_locality_data just need BYOC_MODE?
  #       Alternatively we could have no default and just call data in targets (i.e. same as process_extract_XXX).

  # Read lookup files -------------------------------------------------------
  log_slf_event(stage = "process", status = "start", type = "slf_pc_lookup", year = "all")

  # postcode data
  spd_file <- spd_data %>%
    dplyr::select(
      "pc7",
      # tidyselect::matches("datazone\\d{4}$"),
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
  simd_file <- simd_data %>%
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
  locality_file <- locality_data %>%
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
    ) %>%
    dplyr::mutate(
      run_id = run_id,
      run_date_time = run_date_time
    )

  if (write_to_disk) {
    write_file(
      slf_pc_lookup,
      get_slf_postcode_path(
        BYOC_MODE = BYOC_MODE,
        check_mode = "write"
      ),
      BYOC_MODE = BYOC_MODE,
      group_id = 3206 # hscdiip owner
    )
  }

  log_slf_event(stage = "process", status = "complete", type = "slf_pc_lookup", year = "all")

  return(slf_pc_lookup)
}
