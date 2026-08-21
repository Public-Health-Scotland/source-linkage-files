#' LA Code Lookup
#'
#' @description Return the data for Local Authority lookup.
#'
#' @param denodo_connect Connection to denodo
#' @param BYOC_MODE BYOC MODE
#'
#' @return a [tibble][tibble::tibble-package] with the Local Authority names
#' and codes.
#' @export
#'
#' @family lookup files
get_la_code_opendata_lookup <- function(
  denodo_connect = get_denodo_connection(BYOC_MODE = BYOC_MODE),
  BYOC_MODE = BYOC_MODE
) {
  log_slf_event(stage = "read", status = "start", type = "la_lookup", year = "all")

  # Denodo disconnect
  on.exit(try(DBI::dbDisconnect(denodo_connect), silent = TRUE), add = TRUE)

  # Read data
  la_code_lookup <- dplyr::tbl(
    denodo_connect,
    dbplyr::in_schema("sdl", "sdl_laopendatalookup_source")
  ) %>%
    # Rename variables
    dplyr::select(
      CA = "ca",
      CAName = "caname"
    ) %>%
    dplyr::distinct() %>%
    # Collect
    dplyr::collect() %>%
    dplyr::mutate(
      sending_local_authority_name = dplyr::recode_values(
        .data$caname,
        "City of Edinburgh" ~ "Edinburgh",
        "Na h-Eileanan Siar" ~ "Eilean Siar",
        default = .data$caname
      ) %>%
        stringr::str_replace("\\sand\\s", " \\& ")
    )

  log_slf_event(stage = "read", status = "complete", type = "la_lookup", year = "all")

  return(la_code_lookup)
}
