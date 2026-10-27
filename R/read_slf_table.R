#' Read a Source Linkage File
#'
#' @param year Year of the file to be read, you can specify multiple years
#' which will then be returned as one file. It will be converted to short FY
#' using [format_year()].
#' @param file_version Version of the file (individual / episode).
#' @param denodo_connect Connection to Denodo
#' @param col_select
#' @param columns `r lifecycle::badge("deprecated")` `columns` is no
#' longer used, use `col_select` instead.
#' @param partnerships Optional specify a partnership (hscp2018) or
#' partnerships to select.
#' @param recids Optional specify a recid or recids to select.
#' @param BYOC_MODE BYOC_MODE
#'
#' @return The requested SLF data as a [tibble][tibble::tibble-package]
#' @importFrom rlang .data
read_slf_table <- function(
    years,
    file_version = c("episode", "individual"),
    denodo_connect = get_denodo_connection(BYOC_MODE = BYOC_MODE),
    col_select = NULL,
    columns = lifecycle::deprecated(),
    partnerships = NULL,
    recids = NULL,
    BYOC_MODE = FALSE
) {

  # Check file_version argument
  file_version <- match.arg(file_version)

  # Makes sure recids is NULL if reading individual file
  if (file_version == "individual" && !is.null(recids)){
    recids <- NULL
    warning("Cannot filter by recid, it is not in the individual file.")
  }

  # Convert columns to col_select and display deprecation message
  if (lifecycle::is_present(columns)) {
    lifecycle::deprecate_soft(
      "0.10.0",
      "read_slf_individual(columns)",
      "read_slf_individual(col_select)"
    )
    col_select <- columns
  }

  # Check selected columns are in the episode or individual file
  if (!is.null(col_select)){
    if (file_version == "episode"){
      col_check <- setdiff(col_select, slfhelper::ep_file_vars)
    } else if (file_version == "individual"){
      col_check <- setdiff(col_select, slfhelper::indiv_file_vars)
    }
    if (length(col_check > 0)){
      warning(glue::glue(
        "The following columns are not in the {file_version} file: \n- {paste(col_check, collapse = '\n- ')}"
      ))
    }
  }

  # Put years into a vector if only a single year is provided as a string
  if(is.charcter(years)){
    years <- c(years)
  }

  # Read data from denodo for specified years
  slf_table <- dplyr::tbl(
    denodo_connect,
    dbplyr::in_schema("sdl", glue::glue("sdl_{file_version}_linkage_static"))
  ) %>%
    dplyr::filter(.data$year %in% years)

  # Filter by partnerships
  if (!is.null(partnerships)) {
    slf_table <- slf_table %>%
      dplyr::filter(.data$hscp2018 %in% partnerships)
  }

  # Filter by recids
  if (!is.null(recids)) {
    slf_table <- slf_table %>%
      dplyr::filter(.data$recid %in% recids)
  }

  # Select columns
  if (!is.null(col_select)) {
    slf_table <- slf_table %>%
      dplyr::select(dplyr::any_of(col_select))
  }

  # Collect
  slf_table <- slf_table %>%
    dplyr::collect()

  # Convert age to integer
  if ("age" %in% colnames(slf_table)) {
    slf_table <- slf_table %>%
      dplyr::mutate(age = as.integer(.data$age))
  }

    return(slf_table)
}
