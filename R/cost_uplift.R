#' Uplift costs
#'
#' @param data episode or extract data
#'
#' @return data with uplifted costs
#' @family uplift_costs
apply_cost_uplift <- function(data) {
  data <- data %>%
    # attach a uplift scale as the last column
    lookup_uplift()

  expected_cols <- c(
    "cost_total_net",
    "cost_total_net_inc_dnas",
    paste0(tolower(month.abb[c(4L:12L, 1L:3L)]), "_cost")
  )

  cols_present <- intersect(expected_cols, names(data))

  data <- data %>%
    dplyr::mutate(
      dplyr::across(
        dplyr::any_of(cols_present),
        ~ .x * .data$uplift
      )
    ) %>%
    dplyr::select(-"uplift")

  cli::cli_alert_info("Apply cost uplift function finished at {Sys.time()}")

  return(data)
}

#' Set uplift scale
#'
#' @param data episode or extract data
#'
#' @return data with uplifted costs
#' @family uplift_costs
lookup_uplift <- function(data) {
  # We have set uplifts to use for 2020/21, 2021/22 and 2022/23,
  # provided by Paul Leak.
  # For older years, don't uplift.
  # For years after 2022/23 uplift by an additional 1% per year after the latest
  # cost year (2022/23)
  # For non PLICS recids use uplift of 1 so we won't change anything.

  # To accelerate, create a data frame of year and uplift for match-joining
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

#' The latest financial year for Cost uplift setting
#'
#' @description Get the latest year for cost uplift
#' latest_cost_year() is hard coded in cost_uplift().
#' 2223 is not changed automatically with time passes.
#' It is changed only when we get a new instruction from somewhere about cost uplift.
#' Do not change unless specific instructions.
#' Changing this means that we need to change cost_uplift().
#'
#' @return The financial year format
#'
#' @export
#'
#' @family initialisation
latest_cost_year <- function() {
  "2223"
}
