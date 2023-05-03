#' SLF Data for Testing
#'
#' @description Get the relevant data from the SLFs
#' use, the year, recid and variable names from the
#' 'new' data to make it as efficient as possible.
#'
#' @param new_data a [tibble][tibble::tibble-package] of the
#' new data which the SLF data will be compared to.
#'
#' @return a [tibble][tibble::tibble-package] from the
#' SLF with the relevant recids and variables.
#'
#' @family test functions
#' @seealso produce_source_extract_tests
get_existing_data_for_tests <- function(new_data) {
  year <- new_data %>%
    dplyr::pull(.data$year) %>%
    unique()

  recids <- new_data %>%
    dplyr::pull(.data$recid) %>%
    unique()

  variable_names <- c(
    "anon_chi",
    dplyr::intersect(slfhelper::ep_file_vars, names(new_data))
  )

  slf_data <- suppressMessages(slfhelper::read_slf_episode(
    year = year,
    recids = recids,
    columns = variable_names
  )) %>%
    # Convert anon_chi back to CHI
    dplyr::mutate(
      chi = convert_anon_chi_to_chi(.data[["anon_chi"]]),
      .after = "anon_chi"
    ) %>%
    dplyr::select(-"anon_chi")

  return(slf_data)
}
