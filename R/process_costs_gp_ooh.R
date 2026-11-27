#' Process costs - GP OOH
#'
#' @param ooh_raw_costs Raw GP out of hours costs data
#' @param write_to_disk (optional) Should the data be written to disk default is
#' `TRUE` i.e. write the data to disk.
#' @param BYOC_MODE BYOC_MODE
#' @param run_id Denodo identifier
#' @param run_date_time Denodo identifier
#'
#' @export
process_costs_gp_ooh <- function(ooh_raw_costs = get_gp_ooh_raw_costs_data(BYOC_MODE = BYOC_MODE),
                                 write_to_disk = TRUE,
                                 BYOC_MODE = FALSE,
                                 run_id = NA,
                                 run_date_time = NA) {
  log_slf_event(stage = "process", status = "start", type = "ooh_cost_lookup", year = "all")

  # Data Cleaning ---------------------------------------------------------

  ## data - wide to long ##
  gp_ooh_costs <-
    ooh_raw_costs %>%
    ## create cost per consultation ##
    dplyr::mutate(
      year = as.character(year),
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
    dplyr::mutate(run_id = .env$run_id, run_date_time = .env$run_date_time)

  if (write_to_disk) {
    write_file(
      data = ooh_cost_lookup,
      path = get_gp_ooh_costs_path(
        BYOC_MODE = BYOC_MODE,
        check_mode = "write"
      ),
      group_id = 3206, # hscdiip owner
      BYOC_MODE = BYOC_MODE
    )
  }

  log_slf_event(stage = "process", status = "complete", type = "ooh_cost_lookup", year = "all")

  return(ooh_cost_lookup)
}
