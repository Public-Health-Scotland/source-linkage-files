#' Process the social care client lookup
#'
#' @description This will read and process the
#' social care client lookup
#'
#' @param fyyear The year to process, in the standard format '1718'
#' @param denodo_connect The connection to the SC platform.
#'
#' @return the final data as a [tibble][tibble::tibble-package].
#' @export
#' @family process extracts
read_lookup_sc_client <- function(fyyear,
                                  denodo_connect = get_denodo_connection(BYOC_MODE = BYOC_MODE),
                                  BYOC_MODE) {

  log_slf_event(stage = "read", status = "start", type = "client", year = fyyear)

  check_year_format(fyyear)
  year <- convert_fyyear_to_year(fyyear)

  on.exit(try(DBI::dbDisconnect(denodo_connect), silent = TRUE), add = TRUE)

  # extract fy client data
  client_fy_extract <- dplyr::tbl(
    denodo_connect,
    dbplyr::in_schema("sdl", "sdl_client_fy_snapshot") # TO-DO: Update table name
    ) %>%
    dplyr::filter(.data$financial_year == year) %>%
    dplyr::collect()

  # extract qtr client data
  client_qtr_extract <- dplyr::tbl(
    denodo_connect,
    dbplyr::in_schema("sdl", "sdl_client_qtr_snapshot") # TO-DO: Update table name
    ) %>%
    dplyr::filter(.data$financial_year == year) %>%
    dplyr::collect()

  # Bind client FY and QTR extracts together
  client_extract <- rbind(client_fy_extract, client_qtr_extract)

  client_data <- client_extract %>%
    dplyr::select(
      "sending_location",
      "social_care_id",
      "financial_year",
      "financial_quarter",
      "dementia",
      "mental_health_problems",
      "learning_disability",
      "physical_and_sensory_disability",
      "drugs",
      "alcohol",
      "palliative_care",
      "carer",
      "elder_frail",
      "neurological_condition",
      "autism",
      "other_vulnerable_groups",
      "living_alone",
      "support_from_unpaid_carer",
      "social_worker",
      "type_of_housing",
      "meals",
      "day_care"
    ) %>%
    dplyr::mutate(
      dplyr::across(
        c(
          "sending_location",
          "financial_year",
          "financial_quarter",
          "dementia",
          "mental_health_problems",
          "learning_disability",
          "physical_and_sensory_disability",
          "drugs",
          "alcohol",
          "palliative_care",
          "carer",
          "elder_frail",
          "neurological_condition",
          "autism",
          "other_vulnerable_groups",
          "living_alone",
          "support_from_unpaid_carer",
          "social_worker",
          "type_of_housing",
          "meals",
          "day_care"
        ),
        as.integer
      )
    ) %>%
    dplyr::arrange(
      .data$sending_location,
      .data$social_care_id,
      .data$financial_year,
      .data$financial_quarter
    ) %>%
    dplyr::rename(
      "mental_health_disorders" = "mental_health_problems",
      "elderly_frail" = "elder_frail"
    )

  latest_quarter <- client_data %>%
    dplyr::arrange(dplyr::desc(.data$financial_quarter)) %>%
    dplyr::pull(.data$financial_quarter) %>%
    utils::head(1)
  cli::cli_alert_info(stringr::str_glue("Social care client data for Year {fyyear} is available up to Q{latest_quarter}."))

  log_slf_event(stage = "read", status = "complete", type = "client", year = fyyear)

  return(client_data)
}
