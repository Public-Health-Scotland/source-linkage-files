#' Add smrtype variable based on record ID
#'
#' @param recid A vector of record IDs
#' @param mpat A vector of mpat values
#' @param ipdc A vector of inpatient/day case markers
#' @param hc_service A vector of Home Care service markers
#'
#' @return A vector of SMR types
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
                         hc_service = NULL) {

  # Situation where mpat is provided when not neccessary
  if (!all(recid == "02B") & !is.null(mpat)) {
    cli::cli_abort("You have specified an {.var mpat} value outside of Maternity records.
                   This is not necessary; please re-run the function with {.var mpat} == {.val NULL},
                   which is the default.")
  }

  # Situation where some recids are not in the accepted values
  if (any(!(recid %in% c("02B", "04B", "00B", "AE2", "PIS", "NRS", "01B", "GLS", "CMH", "DN", "HC"))) &
    !any(is.na(recid))) {
    cli::cli_warn(c("i" = "One or more values of {.var recid} do not have an
                   assignable {.var smrtype}"))
  }

  # Situation where some recids are missing
  if (any(is.na(recid))) {
    cli::cli_abort("One or more values of {.var recid} are {.val NA}. Please check
                   the data before continuing.")
  }

  # Situation where maternity records are present without an mpat
  if (any(recid == "02B") & any(is.na(mpat))) {
    cli::cli_abort("In maternity records, {.var mpat} is required to assign an smrtype,
                    and there are some {.val NA} values. Please check the data.")
  }

  # Situation where there are no recid values
  if (all(is.na(recid))) {
    cli::cli_abort("Cannot assign {.var smrtype} when all {.var recid} are {.val NA},
                   please check the data")
  }

  # Situation where no maternity records have an mpat
  if (all(recid == "02B") & all(is.na(mpat))) {
    cli::cli_abort("Cannot assign Maternity smrtype with no valid {.var mpat} values")
  }

  # Situation where an Acute/GLS recid is given but no ipdc marker
  if (any(recid %in% c("01B", "GLS")) & is.null(ipdc)) {
    cli::cli_abort("An {.var ipdc} vector has not been supplied, and therefore Acute/GLS
                   records cannot be given an {.var smrtype}")
  }

  # Recids that can be recoded with no identifier
  if (is.null(mpat) & is.null(ipdc) & is.null(hc_service)) {
    smrtype <- dplyr::case_when(
      recid == "04B" ~ "Psych-IP",
      recid == "00B" ~ "Outpatient",
      recid == "AE2" ~ "A & E",
      recid == "PIS" ~ "PIS",
      recid == "NRS" ~ "NRS Deaths",
      recid == "CMH" ~ "Comm-MH",
      recid == "DN" ~ "DN"
    )
  }
  # Maternity recids, identifier is `mpat`
  else if (all(recid == "02B") & !is.null(mpat) & is.null(ipdc)) {
    smrtype <- dplyr::case_when(
      recid == "02B" & mpat %in% c("1", "3", "5", "7", "A") ~ "Matern-IP",
      recid == "02B" & mpat %in% c("2", "4", "6") ~ "Matern-DC",
      recid == "02B" & mpat == "0" ~ "Matern-HB"
    )
  }
  # Acute recids, identifier is `ipdc`
  else if (is.null(mpat) & !is.null(ipdc)) {
    smrtype <- dplyr::case_when(
      recid == "01B" & ipdc == "I" ~ "Acute-IP",
      recid == "01B" & ipdc == "D" ~ "Acute-DC",
      recid == "GLS" & ipdc == "I" ~ "GLS-IP"
    )
  }
  # Home care
  else if (recid == "HC" & !is.null(hc_service)) {
    smrtype <- dplyr::case_when(
      recid == "HC" & hc_service == 1 ~ "HC-Non-Per",
      recid == "HC" & hc_service == 2 ~ "HC-Per",
      TRUE ~ "HC-Unknown"
    )
  }

  # Return a vector
  return(smrtype)
}
