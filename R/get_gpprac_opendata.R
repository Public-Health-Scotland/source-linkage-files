#' GP Practice details from PHS open data
#'
#' @return The final data as a [tibble][tibble::tibble-package].
#' @export
#'
get_gpprac_opendata <- function(denodo_connect = get_denodo_connection(BYOC_MODE = BYOC_MODE),
                                BYOC_MODE,
                                write_to_disk = TRUE) {
  if (isTRUE(BYOC_MODE)) {
      on.exit(try(DBI::dbDisconnect(denodo_connect), silent = TRUE), add = TRUE)

      gpprac_data <- dplyr::tbl(
        denodo_connect,
        dbplyr::in_schema("sdl", "sdl_gpprac_open_data") # TODO: update table
      ) %>%
        dplyr::collect()
    } else {
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

    if (write_to_disk) {
      write_file(gpprac_data, get_practice_details_path(
          check_mode = "write", BYOC_MODE = BYOC_MODE),
          BYOC_MODE = BYOC_MODE,
          group_id = 3206 # hscdiip owner
      )
    }
  }

  return(gpprac_data)
}
