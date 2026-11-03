get_sdl_processed_data <- function(
  year,
  type,
  denodo_connect = get_denodo_connection(BYOC_MODE = BYOC_MODE),
  BYOC_MODE = BYOC_MODE
) {
  log_slf_event(stage = "read", status = "start", type = type, year = year)

  year <- check_year_format(year)

  # Read local files
  if (isFALSE(BYOC_MODE)) {
    if (type == "ltc") {
      data <- read_file(get_ltcs_path(year, BYOC_MODE = BYOC_MODE))
    } else if (type == "slf_pc_lookup") {
      data <- read_file(get_slf_postcode_path(BYOC_MODE = BYOC_MODE))
    } else if (type == "slf_gpprac_lookup") {
      data <- read_file(
        get_slf_gpprac_path(BYOC_MODE = BYOC_MODE),
        col_select = c("gpprac", "cluster", "hbpraccode")
      )
    } else if (type == "sc_client") {
      data <- read_file(get_sc_client_lookup_path(year, BYOC_MODE = BYOC_MODE))
    } else if (type == "combined_deaths") {
      data <- read_file(get_combined_slf_deaths_lookup_path(year, BYOC_MODE = BYOC_MODE))
    } else {
      data <- read_file(
        get_source_extract_path(
          year,
          type,
          BYOC_MODE = BYOC_MODE
        )
      )
    }

    # Read processed data from Denodo if BYOC_MODE == TRUE
  } else {
    # Disconnect from denodo
    on.exit(try(DBI::dbDisconnect(denodo_connect), silent = TRUE), add = TRUE)

    data <- dplyr::tbl(
      denodo_connect,
      dbplyr::in_schema(
        "sdl",
        get_sdl_names(
          dataset = type,
          version = "processed"
        )
      )
    ) %>%
      dplyr::collect()
  }

  return(data)
}
