#' Process the social care client lookup
#'
#' @description This will read and process the
#' social care client lookup
#'
#' @param sc_dvprod_connection The connection to the SC platform.
#' @param year The year to process
#'
#' @return the final data as a [tibble][tibble::tibble-package].
#' @export
#' @family process extracts
read_lookup_sc_client <- function(sc_dvprod_connection = phs_db_connection(dsn = "DVPROD"), year = convert_fyyear_to_year(year)) {
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
    dplyr::arrange(
      .data$sending_location,
      .data$social_care_id,
      .data$financial_year,
      .data$financial_quarter
    ) %>%
    dplyr::collect()

  return(client_data)
}
