#' Process costs - GP OOH
#'
#' @param denodo_connect connection to denodo
#' @param BYOC_MODE BYOC_MODE
#' @param run_id Denodo identifier
#' @param run_date_time Denodo identifier
#'
#' @export
#'
process_costs_gp_ooh <- function(denodo_connect = get_denodo_connection(BYOC_MODE = BYOC_MODE),
                                 BYOC_MODE = FALSE,
                                 run_id = NA,
                                 run_date_time = NA) {
  log_slf_event(stage = "process", status = "start", type = "ooh_cost_lookup", year = "all")

  on.exit(try(DBI::dbDisconnect(denodo_connect), silent = TRUE), add = TRUE)

  # Costs data ------------------------------------------------------------

  gp_ooh_data <- dplyr::tbl(
    denodo_connect,
    dbplyr::in_schema("sdl", "gp_ooh_costs_source") # TODO: Placeholder table name
  ) %>%
    dplyr::collect()

  # Data Cleaning ---------------------------------------------------------

  ## data - wide to long ##
  gp_ooh_costs <-
    gp_ooh_data %>%
    tidyr::pivot_longer(
      c(ends_with("_Consultations"), ends_with("_Cost")),
      names_to = c("year", ".value"),
      names_pattern = "(\\d{4})_(.+)"
    ) %>%
    ## create cost per consultation ##
    dplyr::mutate(
      cost_per_consultation = Cost * 1000 / Consultations
    ) %>%
    dplyr::select(
      year,
      HB2019,
      Board_Name,
      cost_per_consultation
    )

  # Add in years and increase by 1% for every year after the latest--------

  latest_cost_year <- max(gp_ooh_costs$year)

  gp_ooh_costs_uplifted <-
    dplyr::bind_rows(
      gp_ooh_costs,
      purrr::map(1:5, ~
        gp_ooh_costs %>%
          dplyr::filter(year == latest_cost_year) %>%
          dplyr::group_by(year, HB2019, Board_Name) %>%
          dplyr::summarise(
            cost_per_consultation = cost_per_consultation * (1.01)^.x,
            .groups = "drop"
          ) %>%
          dplyr::mutate(
            year = (as.numeric(convert_fyyear_to_year(year)) + .x) %>%
              convert_year_to_fyyear()
          ))
    ) %>%
    dplyr::arrange(year, HB2019, Board_Name)

  # Output ----------------------------------------------------------------

  ooh_cost_lookup <-
    gp_ooh_costs_uplifted %>%
    dplyr::rename(TreatmentNHSBoardCode = "HB2019") %>%
    dplyr::mutate(
      run_id = run_id,
      run_date_time = run_date_time
    )

  ooh_cost_lookup %>%
    write_file(
      get_gp_ooh_costs_path(check_mode = "write", BYOC_MODE = BYOC_MODE),
      BYOC_MODE = BYOC_MODE,
      group_id = 3206
    )

  log_slf_event(stage = "process", status = "complete", type = "ooh_cost_lookup", year = "all")

  return(ooh_cost_lookup)
}
