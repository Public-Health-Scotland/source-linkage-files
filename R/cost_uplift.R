#' Uplift costs
#'
#' @param data episode data
#' @param uplift
#'
#' @return episode data with uplifted costs
#' @export
cost_uplift <- function(data) {
  data <- data %>%
    # attach a uplift scale as the last column
    uplift_set() %>%
    dplyr::mutate(
      cost_total_net = cost_total_net * uplift,
      cost_total_net_incdnas = cost_total_net_incdnas * uplift,
      apr_cost = apr_cost * uplift,
      may_cost = may_cost * uplift,
      jun_cost = jun_cost * uplift,
      jul_cost = jul_cost * uplift,
      aug_cost = aug_cost * uplift,
      sep_cost = sep_cost * uplift,
      oct_cost = oct_cost * uplift,
      nov_cost = nov_cost * uplift,
      dec_cost = dec_cost * uplift,
      jan_cost = jan_cost * uplift,
      feb_cost = feb_cost * uplift,
      mar_cost = mar_cost * uplift
    ) %>%
    # remove the last uplift column
    dplyr::select(-uplift)
  return(data)
}

#' set uplift scale
#'
#' @param data episode data
#' @param latest_cost_year default financial year '2223'
#'
#' @return episode data with a uplift scale
#' @export
uplift_set <- function(data, latest_cost_year = "2223") {
  # We have set uplifts to use for 2020/21, 2021/22 and 2022/23, provided by Paul Leak.
  # For older years, don't uplift.
  # For years after 2022/23 uplift by an additional 1% per year after the latest cost year (2022/23)
  # For non plics recids use uplift of 1 so we won't change anything.

  # to accelerate, create a data frame of year and uplift for match-joining
  start_year <- 10
  end_year <- 70
  year <- paste0(start_year:end_year, (start_year + 1):(end_year + 1)) %>% as.numeric()
  uplift_df <- data.frame(year, uplift = 1) %>%
    dplyr::mutate(row_no = dplyr::row_number())
  latest_cost_year_row <- uplift_df[year == as.numeric(latest_cost_year), ]$row_no

  uplift_df <- uplift_df %>%
    dplyr::mutate(uplift = dplyr::case_when(
      # We have set uplifts to use for 2020/21, 2021/22 and 2022/23, provided by Paul Leak.
      year == 2021L ~ 1.015,
      year == 2122L ~ 1.015 * 1.041,
      year == 2223L ~ 1.015 * 1.041 * 1.062,
      # For years after 2022/23 uplift by an additional 1% per year after the latest cost year (2022/23)
      year > as.numeric(latest_cost_year) ~ (1.015 * 1.041 * 1.062) * (1.01^(row_no - latest_cost_year_row)),
      # For older years, don't uplift.
      TRUE ~ 1
    )) %>%
    dplyr::mutate(year = as.character(year)) %>%
    dplyr::select(-row_no)

  data <- data %>%
    dplyr::left_join(uplift_df, by = "year") %>%
    # For non plics recids use uplift of 1 so we won't change anything.
    dplyr::mutate(uplift = dplyr::if_else(
      recid %in% c("00B", "01B", "GLS", "02B", "04B", "AE2"),
      uplift,
      1
    ))

  return(data)
}
