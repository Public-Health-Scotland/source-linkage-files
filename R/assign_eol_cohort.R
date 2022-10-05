#' Assign End of Life cohort based on death codes
#'
#' @param data A data frame containing recid and the eleven death diagnosis variables
#'
#' @return A data frame with variables for external causes of death and members of the EoL cohort
#' @export
#'
#' @family Demographic and Service Use Cohort functions
assign_eol_cohort <- function(data) {
  check_variables_exist(data, variables = c(
    "recid", "deathdiag1", "deathdiag2", "deathdiag3", "deathdiag4", "deathdiag5",
    "deathdiag6", "deathdiag7", "deathdiag8", "deathdiag9", "deathdiag10",
    "deathdiag11"
  ))

  external_deaths <- c(
    glue::glue("V{stringr::str_pad(1:99, 2, 'left', '0')}"),
    glue::glue("W{stringr::str_pad(0:99, 2, 'left', '0')}"),
    glue::glue("X{stringr::str_pad(0:99, 2, 'left', '0')}"),
    glue::glue("Y{stringr::str_pad(0:84, 2, 'left', '0')}")
  )
  falls_codes <- c(glue::glue("W{stringr::str_pad(0:19, 2, 'left', '0')}"))

  return_data <- data %>% dplyr::mutate(
    external_cause = dplyr::if_else(
      rowSums(dplyr::across(dplyr::contains("deathdiag"), ~ stringr::str_sub(.x, 1, 3)
      %in% external_deaths)) > 0 &
        rowSums(dplyr::across(dplyr::contains("deathdiag"), ~ stringr::str_sub(.x, 1, 3)
        %in% falls_codes)) == 0, TRUE, NA
    ),
    end_of_life_cohort = .data$recid == "NRS" & is.na(external_cause)
  )
}
