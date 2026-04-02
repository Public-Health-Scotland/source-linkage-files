#' Read LTC IT extract
#'
#' @param file_path Path to the LTC file
#'
#' @return a [tibble][tibble::tibble-package].
#' @export
#'
read_lookup_ltc <- function(denodo_connect = get_denodo_connection(BYOC_MODE = BYOC_MODE),
                            BYOC_MODE) {
  log_slf_event(stage = "read", status = "start", type = "ltc", year = "all")

  # Read data from SQL ------------------------------------------------

  ltc_file <- dplyr::tbl(
    denodo_connect,
    # TODO: check table name after it is finalised
    dbplyr::in_schema("sdl", "sdl_long_term_condition_source")
  ) %>%
    dplyr::select(
      chi              = "patient_chi",
      postcode         = "patient_postcode",
      arth_date        = "arthritis_diag_date",
      asthma_date      = "asthma_diag_date",
      atrialfib_date   = "atrial_fib_diag_date",
      cancer_date      = "cancer_diag_date",
      cvd_date         = "cerebrovasc_dis_diag_date",
      liver_date       = "chron_liver_dis_diag_date",
      copd_date        = "copd_diag_date",
      dementia_date    = "dementia_diag_date",
      diabetes_date    = "diabetes_diag_date",
      epilepsy_date    = "epilepsy_diag_date",
      chd_date         = "heart_disease_diag_date",
      hefailure_date   = "heart_failure_diag_date",
      ms_date          = "mult_sclerosis_diag_date",
      parkinsons_date  = "parkinsons_diag_date",
      refailure_date   = "renal_failure_diag_date",
      congen_date      = "congenital_prob_diag_date",
      bloodbfo_date    = "blood_and_bfo_diag_date",
      endomet_date     = "oth_dis_end_met_diag_date",
      digestive_date   = "oth_dis_dig_sys_diag_date"
    ) %>%
    dplyr::collect() %>%
    dplyr::mutate(
      dplyr::across(
        .cols = dplyr::ends_with("_date"),
        .fns = ~ lubridate::dmy(.)
      )
    )

  chi_check <- ltc_file %>%
    slfhelper::get_chi() %>%
    dplyr::pull(.data$chi) %>%
    phsmethods::chi_check()

  if (!all(chi_check %in% c("Valid CHI", "Missing (Blank)", "Missing (NA)"))) {
    stop("There were bad CHI numbers in the LTC file")
  }

  log_slf_event(stage = "read", status = "complete", type = "ltc", year = "all")

  return(ltc_file)
}
