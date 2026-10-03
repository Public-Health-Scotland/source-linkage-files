#' Read Social Care SDS data
#'
#' @inherit read_sc_all_alarms_telecare
#'
#' @export
read_sc_all_sds <- function(
    denodo_connect = get_denodo_connection(BYOC_MODE = BYOC_MODE),
    BYOC_MODE
) {
  log_slf_event(stage = "read", status = "start", type = "sds", year = "all")

  # Denodo disconnect
  on.exit(try(DBI::dbDisconnect(denodo_connect), silent = TRUE), add = TRUE)

  # Read extract
  sds_full_data <- dplyr::tbl(
    denodo_connect,
    dbplyr::in_schema("sdl", "sdl_sc_sds_source")
  ) %>%
    # Rename variables
    dplyr::select(
      "sending_location",
      "social_care_id",
      "period",
      "sds_period_start_date",
      "sds_period_end_date",
      "sds_start_date",
      "sds_end_date",
      "sds_option_1",
      "sds_option_2",
      "sds_option_3",
      "sds_start_date_after_end_date", # TODO: get fixed
      "sds_start_date_after_period_end_date" # TODO: get removed
    ) %>%
    dplyr::distinct() %>%
    # Collect
    dplyr::collect()

  latest_quarter <- sds_full_data %>%
    dplyr::arrange(dplyr::desc(.data$period)) %>%
    dplyr::pull(.data$period) %>%
    utils::head(1)

  logger::log_info(stringr::str_glue("SDS data is available up to {latest_quarter}."))

  sds_full_data <- sds_full_data %>%
    dplyr::mutate(dplyr::across(c(
      "sending_location", "sds_option_1", "sds_option_2", "sds_option_3"
    ), as.integer))

  log_slf_event(stage = "read", status = "complete", type = "sds", year = "all")

  return(sds_full_data)
}
