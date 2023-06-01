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
#'
#' @return a [tibble][tibble::tibble-package] from the
#' SLF with the relevant recids and variables.
#'
#' @family test functions
#' @seealso produce_source_extract_tests
get_existing_data_for_tests <- function(new_data, file_version = "episode") {
  file_version <- match.arg(file_version, c("episode", "individual"))

  year <- new_data %>%
    dplyr::pull(.data$year) %>%
    unique()

  if (file_version == "episode") {
    recids <- new_data %>%
      dplyr::pull(.data$recid) %>%
      unique()
  }

  variable_names <- c(
    "anon_chi",
    ifelse(
      file_version == "episode",
      dplyr::intersect(slfhelper::ep_file_vars, names(new_data)),
      dplyr::intersect(slfhelper::indiv_file_vars, names(new_data))
    )
  )

  if (file_version == "episode") {
    slf_data <- suppressMessages(slfhelper::read_slf_episode(
      year = year,
      recids = recids,
      columns = variable_names
    ))
  } else {
    slf_data <- suppressMessages(slfhelper::read_slf_individual(
      year = year,
      columns = variable_names
    ))
  }

  return(slfhelper::get_chi(slf_data))
}
