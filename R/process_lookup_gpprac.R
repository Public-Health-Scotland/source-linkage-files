#' Process the SLF gpprac lookup
#'
#' @description This will read and process the gpprac lookup, it will return
#' the final data and also write this out to disk.
#'
#' @param open_data PHS open dataset link to GP practice details
#' @param gpprac_ref_path Path to GP Practice reference file
#' @param spd_path Path to Scottish Postcode Directory.
#' @param write_to_disk (optional) Should the data be written to disk default is
#' `TRUE` i.e. write the data to disk.
#'
#' @return the final data as a [tibble][tibble::tibble-package].
#' @export
#' @family process extracts
process_lookup_gpprac <- function(
    open_data = get_gpprac_opendata(),
    gpprac_ref_path = get_gpprac_ref_path(),
    spd_path = get_spd_path(),
    write_to_disk = TRUE) {
  gpprac_ref_file <- read_file(path = gpprac_ref_path) %>%
    dplyr::select(
      "gpprac" = "praccode",
      "pc7" = "postcode"
    ) %>%
    # Ensure all postcodes are strictly pc7 format
    dplyr::mutate(
      pc7 = phsmethods::format_postcode(.data$pc7, format = "pc7")
    )

  spd_file <- read_file(
    path = spd_path,
    col_select = c(
      "pc7",
      "pc8",
      "hb2018",
      "hscp2018",
      "ca2018"
    )
  )

  # Match cluster information onto the practice reference list
  gpprac_slf_lookup <- dplyr::left_join(
    gpprac_ref_file,
    open_data,
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
      hbpraccode = dplyr::case_match(
        .data$gpprac,
        c(99942L, 99957L, 99961L, 99981L, 99999L) ~ "S08200003",
        99995L ~ "S08200001",
        .default = .data$hbpraccode
      )
    )

  if (write_to_disk) {
    gpprac_slf_lookup %>%
      write_file(get_slf_gpprac_path(check_mode = "write"))
  }

  return(gpprac_slf_lookup)
}
