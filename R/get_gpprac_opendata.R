#' GP Practice details from PHS open data
#'
#' @return The final data as a [tibble][tibble::tibble-package].
#' @export
#'
get_gpprac_opendata <- function(
  denodo_connect = get_denodo_connection(BYOC_MODE = BYOC_MODE),
  BYOC_MODE,
  write_to_disk = TRUE
) {
  log_slf_event(stage = "read", status = "start", type = "gpprac_opendata", year = "all")

  on.exit(try(DBI::dbDisconnect(denodo_connect), silent = TRUE), add = TRUE)

  gpprac_data <- dplyr::tbl(
    denodo_connect,
    dbplyr::in_schema("sdl", "sdl_gpprac_cluster_source") # TO-DO: update table name
  ) %>%
    dplyr::left_join(
      dplyr::tbl(
        denodo_connect,
        dbplyr::in_schema("sdl", "sdl_geography_labels_source") # TO-DO: update table name
      ) %>%
        dplyr::select( # TO-DO: confirm variable names
          hscp,
          hscpname,
          hb,
          hbname
        ),
      by = c("hb", "hscp")
    ) %>%
    dplyr::select(
      gpprac = "practice_code",
      practice_name = "gp_practice_name",
      "postcode",
      cluster = "gp_cluster",
      partnership = "hscpname",
      health_board = "hbname"
    ) %>%
    dplyr::collect() %>%
    # drop NA cluster rows
    tidyr::drop_na("cluster") %>%
    dplyr::mutate(
      # format practice name text
      practice_name = stringr::str_to_title(.data$practice_name),
      # format postcode to strict PC7 format
      postcode = phsmethods::format_postcode(.data$postcode)
    ) %>%
    dplyr::distinct(.data$gpprac, .keep_all = TRUE)

  if (write_to_disk) {
    write_file(gpprac_data, get_practice_details_path(
      check_mode = "write", BYOC_MODE = BYOC_MODE
    ),
    BYOC_MODE = BYOC_MODE,
    group_id = 3206 # hscdiip owner
    )
  }

  log_slf_event(stage = "read", status = "complete", type = "gpprac_opendata", year = "all")

  return(gpprac_data)
}
