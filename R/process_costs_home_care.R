#' Process costs - Home Care
#'
#' @description This will read and process the
#' Home Care costs look up, it will return the final costs look up
#' and (optionally) write it to disk.
#'
#' @param hc_costs_raw Raw home care costs data
#' @param lca_data Local Authority data
#' @param write_to_disk (optional) Should the data be written to disk default is
#' `TRUE` i.e. write the data to disk.
#' @param BYOC_MODE BYOC_MODE
#' @param run_id Denodo identifier
#' @param run_date_time Denodo identifier
#'
#' @return the final look up as a [tibble][tibble::tibble-package].
#' @export
#' @family process cost look ups
process_costs_home_care <- function(hc_costs_raw = get_hc_raw_costs_data(BYOC_MODE = BYOC_MODE),
                                    lca_data = get_la_code_opendata_lookup(BYOC_MODE = BYOC_MODE),
                                    write_to_disk = TRUE,
                                    BYOC_MODE = FALSE,
                                    run_id = NA,
                                    run_date_time = NA) {
  log_slf_event(stage = "process", status = "start", type = "hc_costs", year = "all")

  # Data cleaning ---------------------------------------

  ## Add in years by copying the most recent year ##
  latest_cost_year <- max(hc_costs_raw$year)

  hc_costs <- hc_costs_raw %>%
    dplyr::left_join(
      lca_data,
      by = c("gss_code" = "ca")
    ) %>%
    dplyr::select(year,
      ca_name = caname,
      health_board = hbname,
      hourly_cost
    ) %>%
    dplyr::mutate(ca_name = factor(ca_name)) %>%
    dplyr::mutate(year = as.integer(year))

  ## Increase by 1% for every year after the latest ##
  hc_costs_uplifted <-
    dplyr::bind_rows(
      hc_costs,
      purrr::map(
        1:5,
        ~
          hc_costs %>%
            dplyr::filter(year == latest_cost_year) %>%
            dplyr::group_by(year, ca_name, health_board) %>%
            dplyr::summarise(hourly_cost = hourly_cost * (1.01)^.x, .groups = "drop") %>%
            dplyr::mutate(year = year + .x)
      )
    ) %>%
    dplyr::arrange(year, ca_name)

  # Outfile ---------------------------------------

  outfile <- hc_costs_uplifted %>%
    dplyr::select(-health_board) %>%
    dplyr::mutate(
      run_id = run_id,
      run_date_time = run_date_time
    )

  if (write_to_disk) {
    write_file(
      data = outfile,
      path = get_hc_costs_path(
        BYOC_MODE = BYOC_MODE,
        check_mode = "write"
      ),
      group_id = 3206, # hscdiip owner
      BYOC_MODE = BYOC_MODE
    )
  }

  log_slf_event(stage = "process", status = "complete", type = "ch_costs", year = "all")

  return(outfile)
}
