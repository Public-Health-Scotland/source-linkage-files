#' Process the social care client lookup
#'
#' @description This will read and process the
#' social care client lookup
#'
#' @param year The year to process
#'
#' @return the final data as a [tibble][tibble::tibble-package].
#' @export
#' @family process extracts
read_lookup_sc_client <- function(year) {

# set-up conection to platform
db_connection <- phs_db_connection(dsn = "DVPROD")

# read in data - social care 2 client
client_data <- dplyr::tbl(db_connection, dbplyr::in_schema("social_care_2", "client")) %>%
  dplyr::select(
    .data$sending_location,
    .data$social_care_id,
    .data$financial_year,
    .data$financial_quarter,
    .data$dementia,
    .data$mental_health_problems,
    .data$learning_disability,
    .data$physical_and_sensory_disability,
    .data$drugs,
    .data$alcohol,
    .data$palliative_care,
    .data$carer,
    .data$elderly_frail,
    .data$neurological_condition,
    .data$autism,
    .data$other_vulnerable_groups,
    .data$living_alone,
    .data$support_from_unpaid_carer,
    .data$social_worker,
    .data$type_of_housing,
    .data$meals,
    .data$day_care
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
