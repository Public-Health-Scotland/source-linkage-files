#' Download the LA code lookup
#'
#' @inheritParams phsopendata::get_resource
#'
#' @description Download and process the Local Authority lookup from the Open
#' Data platform
#'
#' @return a [tibble][tibble::tibble-package] with the Local Authority names
#' and codes.
#' @export
la_code_lookup <- function(res_id = "967937c4-8d67-4f39-974f-fd58c4acfda5") {
  la_code_lookup <- phsopendata::get_resource(
    res_id = res_id,
    col_select = c("CA", "CAName")
  ) %>%
    dplyr::distinct() %>%
    dplyr::mutate(
      sending_local_authority_name = dplyr::case_match(
        .data$CAName,
        "City of Edinburgh" ~ "Edinburgh",
        "Na h-Eileanan Siar" ~ "Eilean Siar",
        .default = .data$CAName
      ) %>%
        stringr::str_replace("\\sand\\s", " \\& ")
    )

  return(la_code_lookup)
}
