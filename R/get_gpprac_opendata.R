#' GP Practice details from PHS open data
#'
#' @return The final data as a [tibble][tibble::tibble-package].
#' @export
#'
get_gpprac_opendata <- function() {
  gpprac_data <- phsopendata::get_dataset(
    "gp-practice-contact-details-and-list-sizes"
  ) %>%
    dplyr::left_join(
      phsopendata::get_resource(
        "944765d7-d0d9-46a0-b377-abb3de51d08e",
        col_select = c("HSCP", "HSCPName", "HB", "HBName")
      ),
      by = c("HB", "HSCP")
    ) %>%
    janitor::clean_names() %>%
    dplyr::select(
      gpprac = "practice_code",
      practice_name = "gp_practice_name",
      "postcode",
      cluster = "gp_cluster",
      partnership = "hscp_name",
      health_board = "hb_name"
    ) %>%
    # drop NA cluster rows
    tidyr::drop_na("cluster") %>%
    dplyr::mutate(
      # format practice name text
      practice_name = stringr::str_to_title(.data$practice_name),
      # format postcode to strict PC7 format
      postcode = phsmethods::format_postcode(.data$postcode)
    ) %>%
    dplyr::distinct(.data$gpprac, .keep_all = TRUE) %>%
    write_file(get_practice_details_path(check_mode = "write"),
      group_id = 3206
    ) # hscdiip owner

  return(gpprac_data)
}
