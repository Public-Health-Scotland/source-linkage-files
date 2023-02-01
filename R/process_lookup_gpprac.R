#' Process the SLF gpprac lookup
#'
#' @description This will read and process the
#' gpprac lookup, it will return the final data
#' but also write this out as a zsav and rds.
#'
#' @param open_data PHS open dataset link to gp practice details
#' @param gpprac_ref_file Path to GP Practice reference file
#' @param spd_path Path to Scottish Postcode Directory.#'
#' @param write_to_disk (optional) Should the data be written to disk default is
#' `TRUE` i.e. write the data to disk.
#'
#' @return the final data as a [tibble][tibble::tibble-package].
#' @export
#' @family process extracts

process_lookup_gpprac <- function(open_data = get_gpprac_opendata(),
                                  gpprac_ref_file = get_gpprac_ref_path(),
                                  spd_path = get_spd_path(),
                                  write_to_disk = TRUE) {
  # Read Lookup files ---------------------------------------
  # gp lookup
  gpprac_ref_file <-
    haven::read_sav(gpprac_ref_file) %>%
    # select only praccode and postcode
    dplyr::select(
      gpprac = .data$praccode,
      .data$postcode
    )

  # postcode lookup
  spd_file <- readr::read_rds(spd_path) %>%
    dplyr::select(
      .data$pc7,
      .data$pc8,
      .data$hb2018,
      .data$hscp2018,
      .data$ca2018
    ) %>%
    # rename pc8
    dplyr::rename(postcode = "pc8")


  # Data Cleaning ---------------------------------------

  gpprac_slf_lookup <-
    ## match cluster information onto the practice reference list ##
    dplyr::left_join(
      open_data,
      gpprac_ref_file,
      by = c("gpprac", "postcode")
    ) %>%
    # match on geography info - postcode
    dplyr::left_join(spd_file, by = "postcode") %>%
    # rename hb2018
    dplyr::rename(hbpraccode = "hb2018") %>%
    # order variables
    dplyr::select(
      .data$gpprac,
      .data$pc7,
      .data$postcode,
      .data$cluster,
      .data$hbpraccode,
      .data$hscp2018,
      .data$ca2018
    ) %>%
    # convert ca to lca code
    dplyr::mutate(lca = convert_ca_to_lca(.data$ca2018)) %>%
    # set some known dummy practice codes to consistent Board codes
    dplyr::mutate(
      hbpraccode = dplyr::if_else(
        .data$gpprac %in% c(99942L, 99957L, 99961L, 99981L, 99999L),
        "S08200003",
        .data$hbpraccode
      ),
      hbpraccode = dplyr::if_else(
        .data$gpprac == 99995L,
        "S08200001",
        .data$hbpraccode
      )
    ) %>%
    # sort by gpprac
    dplyr::arrange(.data$gpprac) %>%
    # rename pc8 back - saved in output as pc8
    dplyr::rename(pc8 = "postcode")


  ## save outfile ---------------------------------------

  if (write_to_disk) {
    # Save .rds file
    gpprac_slf_lookup %>%
      write_rds(get_slf_gpprac_path(check_mode = "write"))
  }

  return(gpprac_slf_lookup)
}
