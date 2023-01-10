#' Process th GP OOH Outcomes extract
#'
#' @description This will read and process the
#' GP OOH Outcomes extract, it will return the final data
#' but also write this out as a zsav and rds.
#'
#' @param data The extract to process
#' @param year The year to process, in FY format.
#'
#' @return the final data as a [tibble][tibble::tibble-package].
#' @export
#' @family process extracts
process_extract_ooh_outcomes <- function(data, year) {
  # Only run for a single year
  stopifnot(length(year) == 1L)

  # Check that the supplied year is in the correct format
  year <- check_year_format(year)


  # Outcomes Data ---------------------------------
  ## Data Cleaning
  outcomes_clean <- data %>%
    dtplyr::lazy_dt() %>%
    # Recode outcome
    dplyr::mutate(
      outcome = dplyr::recode(outcome,
        "DEATH" = "00",
        "999/AMBULANCE" = "01",
        "EMERGENCY ADMISSION" = "02",
        "ADVISED TO CONTACT OWN GP SURGERY/GP TO CONTACT PATIENT" = "03",
        "TREATMENT COMPLETED AT OOH/DISCHARGED/NO FOLLOW-UP" = "98",
        "REFERRED TO A&E" = "21",
        "REFERRED TO CPN/DISTRICT NURSE/MIDWIFE" = "22",
        "REFERRED TO MIU" = "21",
        "REFERRED TO SOCIAL SERVICES" = "24",
        "OTHER HC REFERRAL/ADVISED TO CONTACT OTHER HCP (NON-EMERGENCY)" = "29",
        "OTHER" = "99"
      )
    ) %>%
    # Sort so we prefer 'lower' outcomes e.g. Death, over things like 'Other'
    dplyr::group_by(ooh_case_id) %>%
    dplyr::arrange(outcome) %>%
    dplyr::mutate(outcome_n = dplyr::row_number()) %>%
    dplyr::ungroup() %>%
    # use row order to pivot outcomes
    tidyr::pivot_wider(
      names_from = outcome_n,
      names_prefix = "outcome_",
      values_from = outcome
    ) %>%
    dplyr::select(
      "ooh_case_id",
      tidyselect::any_of(c(
        "outcome_1",
        "outcome_2",
        "outcome_3",
        "outcome_4"
      ))
    ) %>%
    dplyr::as_tibble()

  rm(outcomes_extract)

  return(outcomes_clean)
}