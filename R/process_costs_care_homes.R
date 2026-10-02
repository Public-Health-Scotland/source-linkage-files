#' Process costs - Care Homes
#'
#' @description This will read and process the
#' Care Home costs look up, it will return the final costs look up
#' and (optionally) write it to disk.
#'
#' @param ch_costs_data Raw care home costs data
#' @param write_to_disk (optional) Should the data be written to disk default is
#' `TRUE` i.e. write the data to disk.
#' @param BYOC_MODE BYOC_MODE
#' @param run_id Denodo identifier
#' @param run_date_time Denodo identifier
#'
#' @return the final look up as a [tibble][tibble::tibble-package].
#' @export
#' @family process cost look ups
process_costs_care_homes <- function(ch_costs_data = get_ch_raw_costs_data(BYOC_MODE = BYOC_MODE),
                                     write_to_disk = TRUE,
                                     BYOC_MODE = FALSE,
                                     run_id = NA,
                                     run_date_time = NA) {
  log_slf_event(stage = "process", status = "start", type = "ch_costs", year = "all")

  # Data cleaning ---------------------------------------

  ch_costs_data <- ch_costs_data %>%
    # Dates are at end of the fin year so cost are for the fin year to that date
    dplyr::mutate(year = createslf::convert_year_to_fyyear((date %/% 10000L) - 1L)) %>%
    dplyr::filter(year >= "1617") %>%
    dplyr::mutate(funding_source = stringr::str_extract(
      string = key_statistic,
      pattern = "((:?All)|(:?Self)|(:?Publicly))"
    )) %>%
    dplyr::mutate(
      nursing_care_provision = as.integer(stringr::str_detect(key_statistic, "Without"))
    )

  ch_costs_scot <-
    ch_costs_data %>%
    dplyr::filter(council_area_code == "S92000003") %>%
    dplyr::filter(funding_source == "All") %>%
    dplyr::select(year, nursing_care_provision, cost_per_week) %>%
    # Cost per day
    dplyr::mutate(cost_per_day = cost_per_week / 7) %>%
    dplyr::select(-cost_per_week) %>%
    # Compute mean cost for unknown nursing care
    dplyr::bind_rows(
      dplyr::group_by(., year) %>%
        dplyr::summarise(
          nursing_care_provision = NA_real_,
          cost_per_day = mean(cost_per_day)
        )
    )

  # Interpolate any missing years (e.g. 2019/20)
  ch_costs <- ch_costs_scot %>%
    dplyr::group_by(nursing_care_provision) %>%
    dplyr::mutate(cost_per_day = dplyr::if_else(
      is.na(cost_per_day),
      (dplyr::lag(cost_per_day, order_by = year) + dplyr::lead(cost_per_day, order_by = year)) / 2,
      cost_per_day
    )) %>%
    dplyr::ungroup()

  ## Add in years by copying the most recent year ##
  latest_cost_year <- max(ch_costs$year)

  ## Increase by 1% for every year after the latest ##
  ch_costs_uplifted <-
    dplyr::bind_rows(
      ch_costs,
      purrr::map(1:5, ~
        ch_costs %>%
          dplyr::filter(year == latest_cost_year) %>%
          dplyr::group_by(year, nursing_care_provision) %>%
          dplyr::summarise(
            cost_per_day = cost_per_day * (1.01)^.x,
            .groups = "drop"
          ) %>%
          dplyr::mutate(year = (as.numeric(convert_fyyear_to_year(year)) + .x) %>%
            convert_year_to_fyyear()))
    ) %>%
    dplyr::arrange(year, nursing_care_provision) %>%
    dplyr::mutate(
      run_id = run_id,
      run_date_time = run_date_time
    )

  if (write_to_disk) {
    write_file(
      data = ch_costs_uplifted,
      path = get_ch_costs_path(
        BYOC_MODE = BYOC_MODE,
        check_mode = "write"
      ),
      group_id = 3206, # hscdiip owner
      BYOC_MODE = BYOC_MODE
    )
  }

  log_slf_event(stage = "process", status = "complete", type = "ch_costs", year = "all")

  return(ch_costs_uplifted)
}
