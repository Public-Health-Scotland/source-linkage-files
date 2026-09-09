#' Process the SLF postcode lookup
#'
#' @description This will read and process the
#' postcode lookup, it will return the final data
#' and (optionally) write it to disk.
#'
#' @param spd_data Scottish Postcode Directory data.
#' @param simd_data SIMD data.
#' @param locality_data HSCP locality data.
#' @param write_to_disk (optional) Should the data be written to disk default is
#' `TRUE` i.e. write the data to disk.
#' @param BYOC_MODE BYOC_MODE
#' @param run_id run_id for BYOC
#' @param run_date_time run_date_time for BYOC
#'
#' @return the final data as a [tibble][tibble::tibble-package].
#' @export
#' @family process extracts
process_lookup_postcode <- function(
  spd_data = get_spd_data(BYOC_MODE = BYOC_MODE),
  simd_data = get_simd_data(BYOC_MODE = BYOC_MODE),
  locality_data = get_locality_data(BYOC_MODE = BYOC_MODE),
  write_to_disk = TRUE,
  BYOC_MODE = FALSE,
  run_id = NA,
  run_date_time = NA
) {
  log_slf_event(stage = "process", status = "start", type = "slf_pc_lookup", year = "all")

  # Process lookups -------------------------------------------------------

  # Scottish Postcode Directory Lookup
  spd <- spd_data %>%
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

  # SIMD Lookup
  simd <- simd_data %>%
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

  # HSCP Locality Lookup
  locality <- locality_data %>%
    dplyr::mutate(
      locality = tidyr::replace_na(.data$locality, "No Locality Information")
    )

  # Join data together  -----------------------------------------------------

  data <- dplyr::left_join(spd, simd, by = "pc7") %>%
    dplyr::rename(postcode = "pc7") %>%
    dplyr::left_join(locality, by = "datazone2011")

  # Finalise output -----------------------------------------------------

  slf_pc_lookup <- data %>%
    dplyr::mutate(
      run_id = run_id,
      run_date_time = run_date_time
    ) %>%
    dplyr::select(
      "run_id",
      "run_date_time",
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
      data = slf_pc_lookup,
      path = get_slf_postcode_path(
        BYOC_MODE = BYOC_MODE,
        check_mode = "write"
      ),
      group_id = 3206, # hscdiip owner
      BYOC_MODE = BYOC_MODE
    )
  }

  log_slf_event(stage = "process", status = "complete", type = "slf_pc_lookup", year = "all")

  return(slf_pc_lookup)
}
