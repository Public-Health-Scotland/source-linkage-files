#' Add smrtype variable based on record ID
#'
#' @param df A data frame with added SMR type variable
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
add_smr_type <- function(data) {

  if (any(is.na(data$recid)) & !all(is.na(data$recid))) {
    cli::cli_inform(c("i" = "Some values of {.var recid} are {.val NA},
                    please check this is populated throughout the data"))
  }

  if (all(is.na(data$recid))) {
    cli::cli_abort("Cannot assign {.var smrtype} when all {.var recid} are {.val NA},
                   please check the data")
  }

  if (data$recid == "02B" & any(is.na(data$mpat))) {
    cli::cli_inform(c("i" = "In maternity records, {.var mpat} is required to assign
                      an smrtype, and there are some {.val NA} values. Please check the data."))
  }

  if (!any((data$recid %in% c("02B", "04B", "00B", "AE2", "PIS", "NRS"))) &
      !any(is.na(data$recid))) {
    cli::cli_inform(c("i" = "One or more values of {.var recid} do not have an
                   assignable {.var smrtype}"))
  }

  smr_types <- data %>%
    mutate(
      smrtype = case_when(
        recid == "02B" & mpat %in% c("1", "3", "5", "7", "A") ~ "Matern-IP",
        recid == "02B" & mpat %in% c("2", "4", "6") ~ "Matern-DC",
        recid == "02B" & mpat == "0" ~ "Matern-HB",
        recid == "04B" ~ "Psych-IP",
        recid == "00B" ~ "Outpatient",
        recid == "AE2" ~ "A & E",
        recid == "PIS" ~ "PIS",
        recid == "NRS" ~ "NRS Deaths"
      )
    )
}
