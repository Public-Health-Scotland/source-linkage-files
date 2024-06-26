#' Sandpit Extract File Path
#'
#' @description Get the file path for sandpit extracts
#'
#' @param year financial year in string class
#' @param update The update month to use,
#' defaults to [latest_update()]
#' @param type sandpit extract type at, ch, hc, sds, client, or demographics
#'
#' @param ... additional arguments passed to [get_file_path()]
#'
#' @return The path to the sandpit extracts as an [fs::path()]
#' @export
#' @family social care sandpit extract paths
#' @seealso [get_file_path()] for the generic function.
get_sandpit_extract_path <- function(type = c(
                                       "at", "ch", "hc",
                                       "sds", "client", "demographics"
                                     ),
                                     year = NULL,
                                     update = latest_update(), ...) {
  dir <- fs::path(get_slf_dir(), "Social_care", "Sandpit_Extracts")

  file_name <- dplyr::case_match(
    type,
    "at" ~ "anon-sandpit_at_extract",
    "ch" ~ "anon-sandpit_ch_extract",
    "hc" ~ "anon-sandpit_hc_extract",
    "sds" ~ "anon-sandpit_sds_extract",
    "client" ~ "anon-sandpit_sc_client_extract",
    "demographics" ~ "anon-sandpit_sc_demographics_extract"
  )

  if (type == "client") {
    sandpit_extract_path <- fs::path(dir, stringr::str_glue("{file_name}_{year}_{update}.parquet"))
  } else {
    sandpit_extract_path <- fs::path(dir, stringr::str_glue("{file_name}_{update}.parquet"))
  }

  return(sandpit_extract_path)
}
