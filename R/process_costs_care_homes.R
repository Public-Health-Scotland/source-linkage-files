#' Process costs - Care Homes
#'
#' @param denodo_connect connection to denodo
#' @param BYOC_MODE BYOC_MODE
#'
#' @export
#'
process_costs_care_homes <- function(denodo_connect = get_denodo_connection(BYOC_MODE = BYOC_MODE), BYOC_MODE) {
  ## TODO: Remove old code/check API resource in denodo
  # ch_costs_data <- phsopendata::get_resource(
  #   res_id = "4ee7dc84-ca65-455c-9e76-b614091f389f",
  #   col_select = c("Date", "KeyStatistic", "CA", "Value")
  # ) %>%

  ## Read costs from the CHC Open data
  ch_costs_data <- dplyr::tbl(
    denodo_connect,
    dbplyr::in_schema("sdl", "care_home_costs") # TODO: update SDL table
  ) %>%
    janitor::clean_names() %>%
    # Dates are at end of the fin year
    # so cost are for the fin year to that date.
    dplyr::mutate(year = createslf::convert_year_to_fyyear((date %/% 10000L) - 1L)) %>%
    dplyr::filter(year >= "1617") %>%
    dplyr::mutate(funding_source = stringr::str_extract(
      string = key_statistic,
      pattern = "((:?All)|(:?Self)|(:?Publicly))"
    )) %>%
    dplyr::mutate(
      nursing_care_provision = as.integer(stringr::str_detect(key_statistic, "Without"))
    ) %>%
    dplyr::select(
      "year",
      "ca",
      "funding_source",
      "nursing_care_provision",
      cost_per_week = "value"
    )


  # Data cleaning ---------------------------------------
  ch_costs_scot <-
    ch_costs_data %>%
    dplyr::filter(ca == "S92000003") %>%
    dplyr::filter(funding_source == "All") %>%
    dplyr::select(year, nursing_care_provision, cost_per_week) %>%
    # cost per day
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
      (lag(cost_per_day, order_by = year) + lead(cost_per_day, order_by = year)) / 2,
      cost_per_day
    )) %>%
    dplyr::ungroup()

  ## add in years by copying the most recent year ##
  latest_cost_year <- max(ch_costs$year)

  ## increase by 1% for every year after the latest ##
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
    dplyr::arrange(year, nursing_care_provision)


  # Join data together  -----------------------------------------------------

  ## TODO - do we still continue with this check?

  # # match files - to make sure costs haven't changed radically
  # old_costs <- read_file(get_ch_costs_path(update = latest_update())) %>%
  #   dplyr::rename(
  #     cost_old = "cost_per_day"
  #   )
  #
  # matched_costs_data <-
  #   ch_costs_uplifted %>%
  #   dplyr::arrange(year, nursing_care_provision) %>%
  #   # match to new costs
  #   dplyr::full_join(old_costs, by = c("year", "nursing_care_provision")) %>%
  #   # compute difference
  #   dplyr::mutate(pct_diff = (cost_per_day - cost_old) / cost_old * 100.0)
  #
  # summary(matched_costs_data$pct_diff)
  #
  # matched_costs_data %>%
  #   tidyr::pivot_wider(
  #     id_cols = "year",
  #     names_from = "nursing_care_provision",
  #     values_from = "pct_diff"
  #   )

  # Save .rds file
  ch_costs_uplifted %>%
    write_file(get_ch_costs_path(check_mode = "write", BYOC_MODE),
      BYOC_MODE,
      group_id = 3206 # hscdiip owner
    )
}
