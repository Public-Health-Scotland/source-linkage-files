#' Join Deaths data
#'
#' @param data Episode file data
#' @param year financial year, e.g. '1920'
#' @param BYOC_MODE BYOC mode
#'
#' @return The data including the deaths lookup matched
#'         on to the episode file.
join_deaths_data <- function(
  data,
  year,
  BYOC_MODE = FALSE
) {
  slf_deaths_lookup = read_file(get_combined_slf_deaths_lookup_path(BYOC_MODE = BYOC_MODE)) %>%
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
