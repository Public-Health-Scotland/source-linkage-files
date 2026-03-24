#' Read the CHI deaths extract
#'
#' @description This will read the CHI deaths extract and return the data.
#' @param file_path Path to CHI Deaths file
#'
#' @return the final data as a [tibble][tibble::tibble-package].
#' @export
#' @family process extracts
read_it_chi_deaths <- function(denodo_connect = get_denodo_connection(BYOC_MODE = BYOC_MODE),
                               file_path = get_it_deaths_path(), ## CHECK + Is this needed?
                               BYOC_MODE ## Is this needed?
                               ) {

  log_slf_event(stage = "read", status = "start", type = "it_chi_deaths", year = "all")

  on.exit(try(DBI::dbDisconnect(denodo_connect), silent = TRUE), add = TRUE)

  it_chi_deaths <- dplyr::tbl(
    denodo_connect,
    dbplyr::in_schema("sdl", "sdl_XXX")) %>% ## PLACEHOLDER
    dplyr::select(
      anon_chi = "patient_upi", ## CHECK
      death_date_nrs = "patient_dod_nrs", ## CHECK
      death_date_chi = "patient_dod_chi" ## CHECK
      ) %>%
    dplyr::mutate(
      death_date_nrs = lubridate::dmy(.data$death_date_nrs),
      death_date_chi = lubridate::dmy(.data$death_date_chi)
      ) %>%
    dplyr::collect() %>%
    slfhelper::get_anon_chi("anon_chi") ## CHECK

  log_slf_event(stage = "read", status = "complete", type = "it_chi_deaths", year = "all")

  return(it_chi_deaths)
}
