#' GP Practice details from PHS open data
#'
#' @description Return the data for GP Practice details.
#'
#' @param denodo_connect Connection to denodo
#' @param write_to_disk (optional) Should the data be written to disk default is
#' `TRUE` i.e. write the data to disk.
#' @param BYOC_MODE BYOC_MODE
#' @param run_id run_id for BYOC
#' @param run_date_time run_date_time for BYOC
#' @return The final data as a [tibble][tibble::tibble-package].
#'
#' @export
#'
#' @family lookup files
get_gpprac_opendata <- function(
  denodo_connect = get_denodo_connection(BYOC_MODE = BYOC_MODE),
  write_to_disk = TRUE,
  BYOC_MODE = FALSE,
  run_id = NA,
  run_date_time = NA
) {
  log_slf_event(stage = "read", status = "start", type = "gpprac_opendata", year = "all")

  on.exit(try(DBI::dbDisconnect(denodo_connect), silent = TRUE), add = TRUE)

  gpprac_cluster <- dplyr::tbl(
    denodo_connect,
    dbplyr::in_schema("sdl", "sdl_gpprac_cluster_source")
  ) %>%
    dplyr::collect()

  geography_labels <- dplyr::tbl(
    denodo_connect,
    dbplyr::in_schema("sdl", "sdl_geography_labels_source")
  ) %>%
    dplyr::collect()

  gpprac_data <- gpprac_cluster %>%
    dplyr::left_join(
      geography_labels,
      by = c("hb", "hscp")
    ) %>%
    dplyr::mutate(
      run_id = run_id,
      run_date_time = run_date_time
    )
  dplyr::select(
    "run_id",
    "run_date_time",
    gpprac = "practice_code",
    practice_name = "gp_practice_name",
    postcode = "postcode",
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
    dplyr::distinct(.data$gpprac, .keep_all = TRUE)

  if (write_to_disk) {
    write_file(
      data = gpprac_data,
      path = get_practice_details_path(
        BYOC_MODE = BYOC_MODE,
        check_mode = "write"
      ),
      group_id = 3206, # hscdiip owner
      BYOC_MODE = BYOC_MODE
    )
  }

  log_slf_event(stage = "read", status = "complete", type = "gpprac_opendata", year = "all")

  return(gpprac_data)
}
