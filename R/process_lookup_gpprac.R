#' Process the SLF gpprac lookup
#'
#' @description This will read and process the
#' gpprac lookup, it will return the final data
#' but also write this out as a zsav and rds.
#'
#' @param write_to_disk (optional) Should the data be written to disk default is
#' `TRUE` i.e. write the data to disk.
#'
#' @return the final data as a [tibble][tibble::tibble-package].
#' @export
#' @family process extracts

process_lookup_gpprac <- function(write_to_disk = TRUE) {

  # Read lookup files -------------------------------------------------------

  # Retrieve the latest resource from the dataset
  opendata <-
    phsopendata::get_dataset("gp-practice-contact-details-and-list-sizes",
      max_resources = 20
    ) %>%
    janitor::clean_names() %>%
    dplyr::left_join(
      phsopendata::get_resource(
        "944765d7-d0d9-46a0-b377-abb3de51d08e",
        col_select = c("HSCP", "HSCPName", "HB", "HBName")
      ) %>%
        janitor::clean_names(),
      by = c("hb", "hscp")
    ) %>%
    # select variables
    dplyr::select(
      gpprac = .data$practice_code,
      practice_name = .data$gp_practice_name,
      .data$postcode,
      cluster = .data$gp_cluster,
      partnership = .data$hscp_name,
      health_board = .data$hb_name
    ) %>%
    # drop NA cluster rows
    tidyr::drop_na(.data$cluster) %>%
    # format practice name text
    dplyr::mutate(practice_name = stringr::str_to_title(.data$practice_name)) %>%
    # format postcode
    dplyr::mutate(postcode = phsmethods::format_postcode(.data$postcode)) %>%
    # keep distinct gpprac
    dplyr::distinct(.data$gpprac, .keep_all = TRUE) %>%
    # Sort for SPSS matching
    dplyr::arrange(.data$gpprac) %>%
    # Write rds file
    write_rds(get_practice_details_path(check_mode = "write"))


  # Read Lookup files ---------------------------------------
  # gp lookup
  gpprac_ref_file <-
    haven::read_sav(get_gpprac_ref_path()) %>%
    # select only praccode and postcode
    dplyr::select(
      gpprac = .data$praccode,
      .data$postcode
    )

  # postcode lookup
  spd_file <- readr::read_rds(get_spd_path()) %>%
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
    dplyr::left_join(opendata, gpprac_ref_file, by = c("gpprac", "postcode")) %>%
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
        .data$gpprac %in% c(99942, 99957, 99961, 99981, 99999),
        "S08200003",
        .data$hbpraccode
      ),
      hbpraccode = dplyr::if_else(.data$gpprac == 99995, "S08200001", .data$hbpraccode)
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
