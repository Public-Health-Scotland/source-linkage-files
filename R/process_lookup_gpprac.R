#' Process the SLF gpprac lookup
#'
#' @description This will read and process the gpprac lookup, it will return
#' the final data and also write this out to disk.
#'
#' @param gpprac_ref_data GP Practice reference data.
#' @param gpprac_opendata PHS open dataset for GP practice details
#' @param spd_data Scottish Postcode Directory data.
#' @param write_to_disk (optional) Should the data be written to disk default is
#' `TRUE` i.e. write the data to disk.
#' @param BYOC_MODE BYOC_MODE
#' @param run_id run_id for BYOC
#' @param run_date_time run_date_time for BYOC
#'
#' @return the final data as a [tibble][tibble::tibble-package].
#' @export
#' @family process extracts
process_lookup_gpprac <- function(
  gpprac_ref_data = get_gpprac_ref_data(BYOC_MODE = BYOC_MODE),
  gpprac_opendata = get_gpprac_opendata(BYOC_MODE = BYOC_MODE),
  spd_data = get_spd_data(BYOC_MODE = BYOC_MODE),
  write_to_disk = TRUE,
  BYOC_MODE = FALSE,
  run_id = NA,
  run_date_time = NA
) {
  log_slf_event(stage = "process", status = "start", type = "gpprac_lookup", year = "all")

  # Select required variables from the SPD reference file
  spd_file <- spd_data %>%
    dplyr::select(
      "pc7",
      "pc8",
      "hb2018",
      "hscp2018",
      "ca2018"
    )

  # Match cluster information onto the practice reference list
  gpprac_slf_lookup <- dplyr::left_join(
    gpprac_ref_data,
    gpprac_opendata,
    by = "gpprac",
    na_matches = "never",
    relationship = "one-to-one",
    unmatched = "error"
  ) %>%
    # Match on geography info - postcode
    dplyr::left_join(
      spd_file,
      by = "pc7",
      na_matches = "never",
      relationship = "many-to-one"
    ) %>%
    dplyr::rename(hbpraccode = "hb2018") %>%
    dplyr::select(
      "gpprac",
      "pc7",
      "pc8",
      "cluster",
      "hbpraccode",
      "hscp2018",
      "ca2018"
    ) %>%
    dplyr::mutate(
      lca = convert_ca_to_lca(.data$ca2018),
      hbpraccode = dplyr::recode_values(
        .data$gpprac,
        c(99942L, 99957L, 99961L, 99981L, 99999L) ~ "S08200003",
        99995L ~ "S08200001",
        default = .data$hbpraccode
      ),
      run_id = run_id,
      run_date_time = run_date_time
    )

  gpprac_slf_lookup %>%
    write_file(
      get_slf_gpprac_path(check_mode = "write", BYOC_MODE = BYOC_MODE),
      BYOC_MODE = BYOC_MODE,
      group_id = 3206 # hscdiip owner
    )

  log_slf_event(stage = "process", status = "complete", type = "gpprac_lookup", year = "all")

  return(gpprac_slf_lookup)
}
