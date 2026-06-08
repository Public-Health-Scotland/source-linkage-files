#' Read Social Care Home Care data
#'
#' @param sc_dvprod_connection Connection to the SC platform
#'
#' @return an extract of the data as a [tibble][tibble::tibble-package].
#'
#' @export
#'
read_sc_all_home_care <- function(
  denodo_connect = get_denodo_connection(BYOC_MODE = BYOC_MODE),
  BYOC_MODE = FALSE,
  run_id = NA,
  run_date_time = NA
) {
  log_slf_event(stage = "read", status = "start", type = "hc", year = "all")

  on.exit(try(DBI::dbDisconnect(denodo_connect), silent = TRUE), add = TRUE)

  home_care_data <- dplyr::tbl(
    denodo_connect,
    # TODO: check sdl view name
    dbplyr::in_schema("sdl", "sdl_home_care_episode_source")
  ) %>%
    dplyr::select(
      "sending_location",
      "sending_location_name",
      "social_care_id",
      "hc_service_start_date",
      "hc_service_end_date",
      "period",
      "hc_period_start_date",
      "hc_period_end_date",
      "financial_year",
      "hc_service",
      "hc_service_provider",
      "reablement",
      "hc_hours_derived",
      "total_staff_home_care_hours",
      "multistaff_input",
      "hc_start_date_after_end_date",
      "hc_start_date_after_period_end_date"
    ) %>%
    dplyr::mutate(
      hc_period_start_date = dplyr::if_else(
        .data$period == "2017",
        lubridate::as_date("2018-01-01"),
        .data$hc_period_start_date
      )
    ) %>%
    # fix 2017
    dplyr::mutate(period = dplyr::if_else(
      .data$period == "2017",
      "2017Q4",
      .data$period
    )) %>%
    # drop rows start date after end date
    dplyr::distinct() %>%
    dplyr::collect()

  latest_quarter <- home_care_data %>%
    dplyr::arrange(dplyr::desc(.data$period)) %>%
    dplyr::pull(.data$period) %>%
    utils::head(1)
  logger::log_info(stringr::str_glue("Home Care data is available up to {latest_quarter}."))


  home_care_data <- home_care_data %>%
    dplyr::mutate(dplyr::across(c(
      "sending_location",
      "financial_year",
      "hc_service",
      "hc_service_provider",
      "reablement"
    ), as.integer))

  log_slf_event(stage = "read", status = "complete", type = "hc", year = "all")

  return(home_care_data)
}
