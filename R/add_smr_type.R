#' Add smrtype variable based on record ID
#'
#' @param recid A vector of record IDs
#' @param mpat A vector of management of patient values
#' @param ipdc A vector of inpatient/day case markers
#' @param hc_service A vector of Home Care service markers
#' @param main_applicant_flag A vector of Homelessness applicant flags
#' @param consultation_type A vector of GP Out of hours consultation types
#'
#' @return A vector of `smrtype`
#' @export
#'
#' @family Codes
#'
#' @examples
#' add_smr_type(recid = c("04B", "00B", "AE2", "PIS", "NRS"))
#' add_smr_type(recid = c("02B", "02B"), mpat = c("1", "4"))
#' add_smr_type(recid = c("01B", "01B", "GLS"), ipdc = c("I", "D", "I"))
add_smr_type <- function(recid,
                         mpat = NULL,
                         ipdc = NULL,
                         hc_service = NULL,
                         main_applicant_flag = NULL,
                         consultation_type = NULL) {
  # Situation where some recids are not in the accepted values
  if (any(!(recid %in% c(
    "00B",
    "01B",
    "02B",
    "04B",
    "AE2",
    "CH",
    "CMH",
    "DN",
    "GLS",
    "HC",
    "HL1",
    "NRS",
    "OoH",
    "PIS"
  )
  )) &
    !anyNA(recid)) {
    cli::cli_warn(c("i" = "One or more values of {.var recid} do not have an
                   assignable {.var smrtype}"))
  }

  # Situation where some recids are missing
  if (anyNA(recid)) {
    cli::cli_abort(
      "One or more values of {.var recid} are {.val NA}. Please check
                   the data before continuing."
    )
  }

  # Situation where maternity records are present without a corresponding mpat
  if (all(recid == "02B") & anyNA(mpat)) {
    cli::cli_abort(
      "In Maternity records, {.var mpat} is required to assign an smrtype,
                    and there are some {.val NA} values. Please check the data."
    )
  }

  # Situation where acute records are present without a corresponding ipdc
  if (all(recid %in% c("01B", "GLS")) & anyNA(ipdc)) {
    if (all(is.na(ipdc))) {
      cli::cli_abort(
        "In Acute records, {.var ipdc} is required to assign an smrtype, but
        all values are {.val NA}. Please check the code/data."
      )
    }
    cli::cli_warn(
      "In Acute records, {.var ipdc} is required to assign an smrtype, and
      there are some {.val NA} values. Please check the data."
    )
  }

  # Situation where Home Care records are present without a corresponding hc_service
  if (all(recid == "HC") & anyNA(hc_service)) {
    cli::cli_abort(
      "In Home Care records, {.var hc_service} is required to assign an smrtype,
                    and there are some {.val NA} values. Please check the data."
    )
  }

  # Situation where Homelessness records are present without a corresponding main_applicant_flag
  if (all(recid == "HL1") & anyNA(main_applicant_flag)) {
    cli::cli_abort(
      "In Homelessness records, {.var main_applicant_flag} is required to assign an smrtype,
                    and there are some {.val NA} values. Please check the data."
    )
  }

  # Situation where there are no recid values
  if (all(is.na(recid))) {
    cli::cli_abort(
      "Cannot assign {.var smrtype} when all {.var recid} are {.val NA},
                   please check the data"
    )
  }

  # Situation where a maternity recid is given but no mpat marker
  if (all(recid == "02B") & missing(mpat)) {
    cli::cli_abort(
      "An {.var mpat} vector has not been supplied, and therefore Maternity
                   records cannot be given an {.var smrtype}"
    )
  }

  # Situation where an Acute/GLS recid is given but no ipdc marker
  if (any(recid %in% c("01B", "GLS")) & missing(ipdc)) {
    cli::cli_abort(
      "An {.var ipdc} vector has not been supplied, and therefore Acute/GLS
                   records cannot be given an {.var smrtype}"
    )
  }

  # Situation where a Home Care recid is given but no hc_service marker
  if (any(recid == "HC") & missing(hc_service)) {
    cli::cli_abort(
      "An {.var hc_service} vector has not been supplied, and therefore Home Care
                   records cannot be given an {.var smrtype}"
    )
  }

  # Situation where a Homelessness recid is given but no main_applicant_flag marker
  if (any(recid == "HL1") & missing(main_applicant_flag)) {
    cli::cli_abort(
      "A {.var main_applicant_flag} vector has not been supplied, and therefore
                   Homelessness records cannot be given an {.var smrtype}"
    )
  }

  if (all(recid == "02B")) {
    # Maternity recids, identifier is `mpat`
    smrtype <- dplyr::case_when(
      recid == "02B" & mpat %in% c("1", "3", "5", "7", "A") ~ "Matern-IP",
      recid == "02B" & mpat %in% c("2", "4", "6") ~ "Matern-DC",
      recid == "02B" & mpat == "0" ~ "Matern-HB"
    )
  } else if (all(recid %in% c("01B", "GLS"))) {
    # Acute recids, identifier is `ipdc`
    smrtype <- dplyr::case_when(
      recid == "01B" & ipdc == "I" ~ "Acute-IP",
      recid == "01B" & ipdc == "D" ~ "Acute-DC",
      recid == "GLS" & ipdc == "I" ~ "GLS-IP",
      recid == "GLS" ~ "GLS-Unknown",
      .default = "Acute-Unknown"
    )
  } else if (all(recid == "HC")) {
    # Home care
    smrtype <- dplyr::case_when(
      recid == "HC" & hc_service == 1L ~ "HC-Non-Per",
      recid == "HC" & hc_service == 2L ~ "HC-Per",
      .default = "HC-Unknown"
    )
  } else if (all(recid == "HL1")) {
    # Homelessness
    smrtype <- dplyr::case_when(
      recid == "HL1" & main_applicant_flag == "Y" ~ "HL1-Main",
      recid == "HL1" & main_applicant_flag == "N" ~ "HL1-Other"
    )
  } else if (all(recid == "OoH")) {
    smrtype <- dplyr::case_when(
      consultation_type == "DISTRICT NURSE" ~ "OOH-DN",
      consultation_type == "DOCTOR ADVICE/NURSE ADVICE" ~ "OOH-Advice",
      consultation_type == "HOME VISIT" ~ "OOH-HomeV",
      consultation_type == "NHS 24 NURSE ADVICE" ~ "OOH-NHS24",
      consultation_type == "PCEC/PCC" ~ "OOH-PCC",
      consultation_type == "COVID19 ASSESSMENT" ~ "OOH-C19Ass",
      consultation_type == "COVID19 ADVICE" ~ "OOH-C19Adv",
      consultation_type == "COVID19 OTHER" ~ "OOH-C19Oth",
      .default = "OOH-Other"
    )
  } else {
    # Recids that can be recoded with no identifier
    smrtype <- dplyr::case_when(
      recid == "00B" ~ "Outpatient",
      recid == "04B" ~ "Psych-IP",
      recid == "AE2" ~ "A & E",
      recid == "CH" ~ "Care-Home",
      recid == "CMH" ~ "Comm-MH",
      recid == "DN" ~ "DN",
      recid == "NRS" ~ "NRS Deaths",
      recid == "PIS" ~ "PIS"
    )
  }

  if (anyNA(smrtype)) {
    cli::cli_warn(
      "Some {.var smrtype}s were not properly set by {.fun add_smr_type}."
    )
  }

  # Return a vector
  return(smrtype)
}
