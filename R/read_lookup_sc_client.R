#' Process the social care client lookup
#'
#' @description This will read and process the
#' social care client lookup
#'
#' @param year The year to process, in the standard format '1718'
#' @param denodo_connect The connection to the SDL platform.
#' @param BYOC_MODE BYOC_MODE
#'
#' @return the final data as a [tibble][tibble::tibble-package].
#' @export
#' @family process extracts
read_lookup_sc_client <- function(
  year,
  denodo_connect = get_denodo_connection(BYOC_MODE = BYOC_MODE),
  BYOC_MODE
) {
  log_slf_event(stage = "read", status = "start", type = "client", year = year)

  # Check and convert to calendar year
  year <- check_year_format(year, format = "fyyear")
  c_year <- convert_fyyear_to_year(year)

  # Denodo disconnect
  on.exit(try(DBI::dbDisconnect(denodo_connect), silent = TRUE), add = TRUE)

  # Read extract
  client_fy_extract <- dplyr::tbl(
    denodo_connect,
    dbplyr::in_schema("sdl", "sdl_client_fy_snapshot") # TODO: Check table name
  ) %>%
    # Filter by calendar year
    dplyr::filter(
      .data$financial_year == c_year # TODO: Check year column name
    ) %>%
    # Collect
    dplyr::collect()

  # extract qtr client data
  client_qtr_extract <- dplyr::tbl(
    denodo_connect,
    dbplyr::in_schema("sdl", "sdl_client_qtr_snapshot") # TODO: Check table name
  ) %>%
    # Filter by calendar year
    dplyr::filter(.data$financial_year == c_year) %>%
    # Collect
    dplyr::collect()

  # Bind client FY and QTR extracts together
  client_extract <- rbind(client_fy_extract, client_qtr_extract)

  # Select variables
  client_data <- client_extract %>%
    dplyr::select(
      sending_location = "sending_location",
      social_care_id = "social_care_id",
      financial_year = "financial_year",
      financial_quarter = "financial_quarter",
      dementia = "dementia",
      mental_health_disorders = "mental_health_problems",
      learning_disability = "learning_disability",
      physical_and_sensory_disability = "physical_and_sensory_disability",
      drugs = "drugs",
      alcohol = "alcohol",
      palliative_care = "palliative_care",
      carer = "carer",
      elderly_frail = "elder_frail",
      neurological_condition = "neurological_condition",
      autism = "autism",
      other_vulnerable_groups = "other_vulnerable_groups",
      living_alone = "living_alone",
      support_from_unpaid_carer = "support_from_unpaid_carer",
      social_worker = "social_worker",
      type_of_housing = "type_of_housing",
      meals = "meals",
      day_care = "day_care"
    ) %>%
    # Data type modification
    dplyr::mutate(
      dplyr::across(
        c(
          "sending_location",
          "financial_year",
          "financial_quarter",
          "dementia",
          "mental_health_disorders",
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
    # Re-order rows
    dplyr::arrange(
      .data$sending_location,
      .data$social_care_id,
      .data$financial_year,
      .data$financial_quarter
    )

  # Print data available
  latest_quarter <- client_data %>%
    dplyr::arrange(dplyr::desc(.data$financial_quarter)) %>%
    dplyr::pull(.data$financial_quarter) %>%
    utils::head(1)
  cli::cli_alert_info(stringr::str_glue("Social care client data for Year {year} is available up to Q{latest_quarter}."))

  log_slf_event(stage = "read", status = "complete", type = "client", year = year)

  return(client_data)
}
