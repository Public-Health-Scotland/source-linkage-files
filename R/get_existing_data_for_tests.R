#' SLF Data for Testing
#'
#' @description Get the relevant data from the SLFs
#' use, the year, recid and variable names from the
#' 'new' data to make it as efficient as possible.
#'
#' @param new_data a [tibble][tibble::tibble-package] of the
#' new data which the SLF data will be compared to.
#' @param file_version whether to test against the "episode" file (the default)
#' or the "individual" file.
#' @param anon_chi Default set as FALSE. For use in episode tests where
#' we want anon_chi instead of chi.
#'
#' @return a [tibble][tibble::tibble-package] from the
#' SLF with the relevant recids and variables.
#'
#' @family test functions
#' @seealso produce_source_extract_tests
#' @export
get_existing_data_for_tests <- function(new_data, file_version = "episode", anon_chi = FALSE) {
  file_version <- match.arg(file_version, c("episode", "individual"))

  year <- new_data %>%
    dplyr::pull(.data$year) %>%
    unique()

  if (file_version == "episode") {
    recids <- new_data %>%
      dplyr::pull(.data$recid) %>%
      unique()
  }

  if (file_version == "episode") {
    variable_names <- c(
      "anon_chi",
      dplyr::intersect(slfhelper::ep_file_vars, tolower(names(new_data)))
    )
    if ("hscp" %in% names(new_data)) {
      variable_names <- c("hscp2018", variable_names)
    }
  } else if (file_version == "individual") {
    variable_names <- c(
      "anon_chi",
      dplyr::intersect(slfhelper::indiv_file_vars, tolower(names(new_data)))
    )
  }

  if (file_version == "episode") {
    slf_data <- suppressMessages(slfhelper::read_slf_episode(
      year = year,
      recids = recids,
      col_select = variable_names
    ))
  } else {
    slf_data <- suppressMessages(slfhelper::read_slf_individual(
      year = year,
      col_select = variable_names
    ))
  }

  if (anon_chi == FALSE) {
    slf_data <- slf_data %>%
      slfhelper::get_chi()
  } else {
    slf_data <- slf_data
  }

  return(slf_data)
}
