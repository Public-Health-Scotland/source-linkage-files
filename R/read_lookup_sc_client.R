#' Process the social care client lookup
#'
#' @description This will read and process the
#' social care client lookup
#'
#' @param fyyear The year to process, in the standard format '1718'
#' @param sc_dvprod_connection The connection to the SC platform.
#'
#' @return the final data as a [tibble][tibble::tibble-package].
#' @export
#' @family process extracts
read_lookup_sc_client <- function(fyyear,
                                  sc_dvprod_connection = phs_db_connection(dsn = "DVPROD")) {
  check_year_format(fyyear)
  year <- convert_fyyear_to_year(fyyear)

  # read in data - social care 2 client
  client_data <- dplyr::tbl(sc_dvprod_connection, dbplyr::in_schema("social_care_2", "client")) %>%
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
      "elderly_frail",
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
    dplyr::filter(.data$financial_year == year) %>%
    dplyr::collect() %>%
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
          "elderly_frail",
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
    dplyr::rename("mental_health_disorders" = "mental_health_problems") %>%
    dplyr::collect()

  latest_quarter <- client_data %>%
    dplyr::arrange(desc(financial_quarter)) %>%
    dplyr::pull(financial_quarter) %>%
    head(1)
  cli::cli_alert_info(stringr::str_glue("Social care client data for Year {fyyear} is available up to Q{latest_quarter}."))


  if (!fs::file_exists(get_sandpit_extract_path(type = "client", year = fyyear))) {
    client_data %>%
      write_file(get_sandpit_extract_path(type = "client", year = fyyear))

    client_data %>%
      process_tests_sc_sandpit(type = "client", year = fyyear)
  } else {
    client_data <- client_data
  }

  return(client_data)
}
