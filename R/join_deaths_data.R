#' Join Deaths data
#'
#' @param data Episode file data
#' @param year financial year, e.g. '1920'
#' @param BYOC_MODE BYOC mode
#' @param slf_deaths_lookup combined deaths lookup
#'
#' @return The data including the deaths lookup matched
#'         on to the episode file.
join_deaths_data <- function(
  data,
  year,
  slf_deaths_lookup = get_sdl_processed_data(year, type = "combined_deaths", BYOC_MODE = BYOC_MODE),
  BYOC_MODE = FALSE
) {
  slf_deaths_lookup <- slf_deaths_lookup %>%
    # Filter the chi death dates to the FY as the lookup is by FY
    dplyr::filter(fy == year) %>%
    # use the BOXI NRS death date by default, but if it's missing, use the chi death date.
    dplyr::mutate(
      deceased = TRUE
    )

  data <- data %>%
    dplyr::left_join(
      slf_deaths_lookup %>%
        dplyr::distinct(.data$anon_chi, .keep_all = TRUE),
      by = "anon_chi",
      na_matches = "never",
      relationship = "many-to-one"
    )

  cli::cli_alert_info("Join deaths data function finished at {Sys.time()}")

  return(data)
}
