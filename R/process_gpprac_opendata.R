#' Process the GP Practice Open Data lookup
#'
#' @description This will read and process the GP Practice details (Geography
#' Labels and Cluster Information), it will return the final data
#' and (optionally) write it to disk.
#'
#' @param gpprac_cluster GP Practice Cluster Information
#' @param geography_labels GP Practice Geography Labels
#' @param write_to_disk (optional) Should the data be written to disk default is
#' `TRUE` i.e. write the data to disk.
#' @param BYOC_MODE BYOC_MODE
#' @param run_id run_id for BYOC
#' @param run_date_time run_date_time for BYOC
#'
#' @return The final data as a [tibble][tibble::tibble-package].
#' @export
#' @family lookup files
process_gpprac_opendata <- function(
  gpprac_cluster = get_gpprac_cluster(BYOC_MODE = BYOC_MODE),
  geography_labels = get_geography_labels(BYOC_MODE = BYOC_MODE),
  write_to_disk = TRUE,
  BYOC_MODE = FALSE,
  run_id = NA,
  run_date_time = NA
) {
  log_slf_event(stage = "process", status = "start", type = "gpprac_opendata", year = "all")

  gpprac_data <- gpprac_cluster %>%
    dplyr::left_join(
      geography_labels,
      by = c("hb", "hscp")
    ) %>%
    dplyr::mutate(
      run_id = run_id,
      run_date_time = run_date_time
    ) %>%
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
    # Drop NA cluster rows
    tidyr::drop_na("cluster") %>%
    dplyr::mutate(
      # Format practice name text
      practice_name = stringr::str_to_title(.data$practice_name),
      # Format postcode to strict PC7 format
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

  log_slf_event(stage = "process", status = "complete", type = "gpprac_opendata", year = "all")

  return(gpprac_data)
}
