#' Uplift costs
#'
#' @param data episode data
#'
#' @return episode data with uplifted costs
apply_cost_uplift <- function(data) {
  data <- data %>%
    # attach a uplift scale as the last column
    lookup_uplift() %>%
    dplyr::mutate(
      cost_total_net = .data$cost_total_net * .data$uplift,
      cost_total_net_inc_dnas = .data$cost_total_net_inc_dnas * .data$uplift,
      apr_cost = .data$apr_cost * .data$uplift,
      may_cost = .data$may_cost * .data$uplift,
      jun_cost = .data$jun_cost * .data$uplift,
      jul_cost = .data$jul_cost * .data$uplift,
      aug_cost = .data$aug_cost * .data$uplift,
      sep_cost = .data$sep_cost * .data$uplift,
      oct_cost = .data$oct_cost * .data$uplift,
      nov_cost = .data$nov_cost * .data$uplift,
      dec_cost = .data$dec_cost * .data$uplift,
      jan_cost = .data$jan_cost * .data$uplift,
      feb_cost = .data$feb_cost * .data$uplift,
      mar_cost = .data$mar_cost * .data$uplift
    ) %>%
    # remove the last uplift column
    dplyr::select(-"uplift")

  return(data)
}

#' Set uplift scale
#'
#' @param data episode data
#'
#' @return episode data with a uplift scale
lookup_uplift <- function(data) {
  # We have set uplifts to use for 2020/21, 2021/22 and 2022/23,
  # provided by Paul Leak.
  # For older years, don't uplift.
  # For years after 2022/23 uplift by an additional 1% per year after the latest
  # cost year (2022/23)
  # For non PLICS recids use uplift of 1 so we won't change anything.

  # to accelerate, create a data frame of year and uplift for match-joining
  start_year <- 10L
  end_year <- as.integer(format(Sys.Date(), "%y"))
  year <- as.integer(paste0(
    start_year:end_year,
    (start_year + 1L):(end_year + 1L)
  ))
  uplift_df <- tibble::tibble(year,
    uplift = 1.0
  ) %>%
    dplyr::mutate(row_no = dplyr::row_number())
  latest_cost_year_row <- uplift_df[year == as.integer(latest_cost_year()), ][["row_no"]]

  uplift_df <- uplift_df %>%
    dplyr::mutate(uplift = dplyr::case_when(
      # We have set uplifts to use for 2020/21, 2021/22 and 2022/23,
      # provided by Paul Leak.
      year == 2021L ~ 1.015,
      year == 2122L ~ 1.015 * 1.041,
      year == 2223L ~ 1.015 * 1.041 * 1.062,
      # For years after 2022/23 uplift by an additional 1% per year after
      # the latest cost year (2022/23)
      year > as.integer(latest_cost_year()) ~ (1.015 * 1.041 * 1.062) * (1.01^(.data$row_no - latest_cost_year_row)),
      # For older years, don't uplift.
      .default = 1.0
    )) %>%
    dplyr::mutate(year = as.character(.data$year)) %>%
    dplyr::select(-"row_no")

  data <- data %>%
    dplyr::left_join(uplift_df, by = "year") %>%
    # For non PLICS recids use uplift of 1 so we won't change anything.
    dplyr::mutate(uplift = dplyr::if_else(
      .data$recid %in% c("00B", "01B", "GLS", "02B", "04B", "AE2"),
      .data$uplift,
      1.0
    ))

  return(data)
}
