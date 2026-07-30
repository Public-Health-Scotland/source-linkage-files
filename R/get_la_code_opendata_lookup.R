#' Download the LA code lookup
#'
#' @description Download and process the Local Authority lookup from the Open
#' Data platform
#'
#' @return a [tibble][tibble::tibble-package] with the Local Authority names
#' and codes.
#' @export
get_la_code_opendata_lookup <- function(denodo_connect = get_denodo_connection(BYOC_MODE = BYOC_MODE)) {
  on.exit(try(DBI::dbDisconnect(denodo_connect), silent = TRUE), add = TRUE)

  la_code_lookup <- dplyr::tbl(
    denodo_connect,
    dbplyr::in_schema("sdl", "sdl_laopendatalookup_source")
  ) %>%
    dplyr::collect() %>%
    dplyr::distinct() %>%
    dplyr::mutate(
      sending_local_authority_name = dplyr::recode_values(
        .data$CAName,
        "City of Edinburgh" ~ "Edinburgh",
        "Na h-Eileanan Siar" ~ "Eilean Siar",
        default = .data$CAName
      ) %>%
        stringr::str_replace("\\sand\\s", " \\& ")
    )

  return(la_code_lookup)
}
