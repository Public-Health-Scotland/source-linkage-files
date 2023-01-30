#' Read SC demographics
#'
#' @param sc_connection Connection to the sc platform
#'
#' @return a [tibble][tibble::tibble-package]
#' @export
#'
read_lookup_sc_demographics <- function(sc_connection = phs_db_connection(dsn = "DVPROD")) {
  # Read in data---------------------------------------

  # read in data - social care 2 demographic
  sc_demog <- dplyr::tbl(
    sc_connection,
    dbplyr::in_schema(
      "social_care_2",
      "demographic_snapshot"
    )
  ) %>%
    dplyr::select(
      "latest_record_flag", "extract_date", "sending_location", "social_care_id", "upi",
      "chi_upi", "submitted_postcode", "chi_postcode", "submitted_date_of_birth",
      "chi_date_of_birth", "submitted_gender", "chi_gender_code"
    ) %>%
    dplyr::collect()

  # variable types
  sc_demog <- sc_demog %>%
    dplyr::mutate(
      submitted_gender = as.numeric(.data$submitted_gender),
      chi_gender_code = as.numeric(.data$chi_gender_code)
    )

  return(sc_demog)
}
