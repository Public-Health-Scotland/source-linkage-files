#' Homelessness Completeness SG publication figures
#'
#' @description Return the data for Homelessness Completeness lookup.
#'
#' @param denodo_connect Connection to denodo
#' @param BYOC_MODE BYOC MODE
#'
#' @return a [tibble][tibble::tibble-package].
#' @export
#'
#' @family lookup files
get_sg_pub_data <- function(
  denodo_connect = get_denodo_connection(BYOC_MODE = BYOC_MODE),
  BYOC_MODE = BYOC_MODE
) {
  log_slf_event(stage = "read", status = "start", type = "homelessness_completeness", year = "all")

  # Denodo disconnect
  on.exit(try(DBI::dbDisconnect(denodo_connect), silent = TRUE), add = TRUE)

  # Read data
  sg_pub_data <- dplyr::tbl(
    denodo_connect,
    dbplyr::in_schema("sdl", "sdl_homelessness_completeness_source")
  ) %>%
    dplyr::select(
      "CAName" = "local_authority",
      "sg_year" = "fin_year",
      "sg_all_assessments", "sg_all_assessments"
    ) %>%
    # Collect
    dplyr::collect() %>%
    dplyr::mutate(sg_year = convert_year_to_fyyear(sg_year)) %>%
    dplyr::summarise(
      sg_all_assessments = sum(sg_all_assessments),
      .by = c("CAName", "sg_year")
    ) %>%
    dplyr::arrange(CAName, sg_year)

  log_slf_event(stage = "read", status = "complete", type = "homelessness_completeness", year = "all")

  return(sg_pub_data)
}
