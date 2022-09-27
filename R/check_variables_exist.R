#' Check variables exist in data
#'
#' @param data a dataframe to check
#' @param variables a character vector of variable names which should be in
#' the data
#'
#' @return TRUE (invisibly) if all variables are present otherwise it will
#' throw an informative error message
#' @export
check_variables_exist <- function(data, variables) {

  if (!inherits(variables, "character")) {
    cli::cli_abort("{.arg variables} must be a {.cls character} not a
                   {.cls {class(variables)}}.")
  }

  if (!inherits(data, "data.frame")) {
    cli::cli_abort("{.arg data} must be a {.cls tbl_df} not a
                   {.cls {class(data)}}.")
  }

  variables_present <- variables %in% names(data)

  if (all(variables_present)) {
    return(invisible(TRUE))
  } else {
    missing_variables <- variables[which(!variables_present)]

    n_missing <- length(missing_variables)

    cli::cli_abort(
      "{cli::qty(n_missing)}Variable{?s} {.val {missing_variables}} {?is/are}
      required, but {?is/are} missing from {.arg data}."
    )
  }
}
