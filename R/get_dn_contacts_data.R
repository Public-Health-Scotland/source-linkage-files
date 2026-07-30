#' District Nursing Contacts Data
#'
#' @description Return the data for District Nursing contacts.
#'
#' @param denodo_connect Connection to denodo
#' @param BYOC_MODE BYOC MODE
#'
#' @return a [tibble][tibble::tibble-package].
#' @export
#'
#' @family lookup files
get_dn_contacts_data <- function(
    denodo_connect = get_denodo_connection(BYOC_MODE = BYOC_MODE),
    BYOC_MODE
) {
  log_slf_event(stage = "read", status = "start", type = "dn_contact_lookup", year = "all")

  # Denodo disconnect
  on.exit(try(DBI::dbDisconnect(denodo_connect), silent = TRUE), add = TRUE)

  # Read data
  dn_contacts_data <- dplyr::tbl(
    denodo_connect,
    dbplyr::in_schema("sdl", "sdl_dn_contacts_source")
  ) %>%
    # Rename variables
    dplyr::select(
      contact_financial_year = "contact_financial_year",
      hb2019 = "treatment_nhs_board_code_9",
      treatment_nhs_board_name = "treatment_nhs_board_name",
      number_of_contacts = "number_of_contacts"
    ) %>%
    # Collect
    dplyr::collect()

  log_slf_event(stage = "read", status = "complete", type = "dn_contact_lookup", year = "all")

  return(dn_contacts_data)
}
