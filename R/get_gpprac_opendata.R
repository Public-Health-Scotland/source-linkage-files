#' GP Practice details from PHS open data
#'
#' @return The final data as a [tibble][tibble::tibble-package].
#' @export
#'
get_gpprac_opendata <- function() {
  gpprac_data <- phsopendata::get_dataset(
    "gp-practice-contact-details-and-list-sizes",
    max_resources = 20L
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
    dplyr::mutate(
      practice_name = stringr::str_to_title(.data$practice_name)
    ) %>%
    # format postcode
    dplyr::mutate(
      postcode = phsmethods::format_postcode(.data$postcode)
    ) %>%
    # keep distinct gpprac
    dplyr::distinct(.data$gpprac, .keep_all = TRUE) %>%
    # Sort for SPSS matching
    dplyr::arrange(.data$gpprac) %>%
    # Write rds file
    write_file(get_practice_details_path(check_mode = "write"))

  return(gpprac_data)
}
