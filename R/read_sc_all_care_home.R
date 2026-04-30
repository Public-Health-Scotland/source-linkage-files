#' Read Social Care - Care Home data
#'
#' @param denodo_connect Connection to denodo
#' @param BYOC_MODE BYOC_MODE
#'
#' @return an extract of the data as a [tibble][tibble::tibble-package].
#'
#' @export
#'
read_sc_all_care_home <- function(denodo_connect = get_denodo_connection(BYOC_MODE = BYOC_MODE), BYOC_MODE) {
  log_slf_event(stage = "read", status = "start", type = "ch", year = "all")

  ch_data <- dplyr::tbl(
    denodo_connect,
    dbplyr::in_schema("social_care_2", "carehome_snapshot") # TODO: update SDL table
  ) %>%
    dplyr::select(
      "ch_name",
      "ch_postcode",
      "sending_location",
      "social_care_id",
      "period",
      "period_start_date",
      "period_end_date",
      "ch_provider",
      "ch_provider_description",
      "reason_for_admission",
      "type_of_admission",
      "nursing_care_provision",
      "ch_admission_date",
      "ch_discharge_date",
      "age"
    ) %>%
    dplyr::distinct() %>%
    dplyr::collect()

  latest_quarter <- ch_data %>%
    dplyr::arrange(dplyr::desc(.data$period)) %>%
    dplyr::pull(.data$period) %>%
    utils::head(1)
  cli::cli_alert_info(stringr::str_glue("Care Home data is available up to {latest_quarter}."))

  ch_data <- ch_data %>%
    # Correct FY 2017 as data collection only started in 2017 Q4
    dplyr::mutate(period = dplyr::if_else(
      .data$period == "2017",
      "2017Q4",
      .data$period
    )) %>%
    dplyr::mutate(
      period_start_date = dplyr::if_else(
        .data$period == "2017",
        lubridate::as_date("2018-01-01"),
        .data$period_start_date
      )
    ) %>%
    dplyr::mutate(
      dplyr::across(c(
        "sending_location",
        "ch_provider",
        "reason_for_admission",
        "type_of_admission",
        "nursing_care_provision"
      ), as.integer)
    )

  log_slf_event(stage = "read", status = "complete", type = "ch", year = "all")

  return(ch_data)
}
