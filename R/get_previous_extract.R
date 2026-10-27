#' Get SDL Previous Extract
#'
#' @description Get a previous extract relevant from Denodo using the run_id.
#'
#' @param type Type code
#' @param year Financial year
#' @param benchmark_run_id
#' @param denodo_connect Connection to Denodo
#' @param BYOC_MODE BYOC_MODE
#'
#' @return a [tibble][tibble::tibble-package] the previous extract from Denodo.
#'
#' @family test functions
#' @seealso get_existing_data_for_tests
#' @export
get_previous_extract <- function(
    type,
    year,
    benchmark_run_id = NA,
    denodo_connect = get_denodo_connection(BYOC_MODE = BYOC_MODE),
    BYOC_MODE = FALSE
){
  previous_extract <- dplyr::tbl(
    denodo_connect,
    dbplyr::in_schema("sdl", get_sdl_names(type, "processed"))
  ) %>%
    # Filter run_id
    dplyr::filter(
      .data$run_id == benchmark_run_id
    )

  if (year != "all"){
    # Filter year if not all
    previous_extract <- previous_extract %>%
      dplyr::filter(
        .data$year == year
      )
  }

    # Collect
  previous_extract <- previous_extract %>%
    dplyr::collect()

  return(previous_extract)
}
