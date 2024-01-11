#' Read SC demographics
#'
#' @param sc_connection Connection to the sc platform
#'
#' @return a [tibble][tibble::tibble-package]
#' @export
#'
read_lookup_sc_demographics <- function(sc_connection = phs_db_connection(dsn = "DVPROD")) {
  sc_demog <- dplyr::tbl(
    sc_connection,
    dbplyr::in_schema("social_care_2", "demographic_snapshot")
  ) %>%
    dplyr::select(
      "latest_record_flag",
      "period",
      "sending_location",
      "sending_location_name",
      "social_care_id",
      "chi_upi",
      "chi_date_of_birth",
      "date_of_death",
      "chi_postcode",
      "submitted_postcode",
      "chi_gender_code"
    ) %>% dplyr::collect() %>%
    dplyr::mutate(
      dplyr::across(c(
        "latest_record_flag",
        "sending_location",
        "chi_gender_code"
      ), as.integer)
    )%>%
    dplyr::distinct()

  return(sc_demog)
}


