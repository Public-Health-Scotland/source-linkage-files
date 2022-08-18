#' Add smrtype variable based on record ID
#'
#' @param recid A vector of record IDs
#' @param mpat A vector of mpat values
#'
#' @return A vector of SMR types
#' @export
#'
#' @family Codes
#'
#' @examples
#' x <- tibble::tibble(
#'   recid = c("02B", "02B", "02B", "04B", "00B", "AE2", "PIS", "NRS"),
#'   mpat = c("1", "2", "0", "", "", "", "", "")
#' )
#' add_smr_type(x)
add_smr_type <- function(recid, mpat = NULL) {

  # Situation where some recids are missing
  if (any(is.na(recid)) & !all(is.na(recid))) {
    cli::cli_inform(c("i" = "Some values of {.var recid} are {.val NA},
                    please check this is populated throughout the data"))
  }

  # Situation where some recids are not in the accepted values
  if (any(!(recid %in% c("02B", "04B", "00B", "AE2", "PIS", "NRS"))) &
    !any(is.na(recid))) {
    cli::cli_inform(c("i" = "One or more values of {.var recid} do not have an
                   assignable {.var smrtype}"))
  }

  # Situation where maternity records are present without an mpat
  if (any(recid == "02B") & any(is.na(mpat)) & !all(is.na(mpat))) {
    cli::cli_inform(c("i" = "In maternity records, {.var mpat} is required to assign
                      an smrtype, and there are some {.val NA} values. Please check the data."))
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


  # Recode non-maternity recids
  if (missing(mpat)) {
    smrtype <- dplyr::case_when(
      recid == "04B" ~ "Psych-IP",
      recid == "00B" ~ "Outpatient",
      recid == "AE2" ~ "A & E",
      recid == "PIS" ~ "PIS",
      recid == "NRS" ~ "NRS Deaths"
    )
  } else {
    # Recode all recids
    smrtype <- dplyr::case_when(
      recid == "02B" & mpat %in% c("1", "3", "5", "7", "A") ~ "Matern-IP",
      recid == "02B" & mpat %in% c("2", "4", "6") ~ "Matern-DC",
      recid == "02B" & mpat == "0" ~ "Matern-HB",
      recid == "04B" ~ "Psych-IP",
      recid == "00B" ~ "Outpatient",
      recid == "AE2" ~ "A & E",
      recid == "PIS" ~ "PIS",
      recid == "NRS" ~ "NRS Deaths"
    )
  }

  # Return a vector
  return(smrtype)
}
