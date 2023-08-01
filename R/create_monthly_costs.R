#' Create Monthly Costs
#'
#' @description Assign monthly costs using a cost variable
#' and vector containing monthly beddays.
#'
#' @param data Data containing bedday variables,
#' see [create_monthly_beddays] to create
#' @param yearstay The variable containing the total
#' number of beddays in the year, default is `yearstay`
#' @param cost_total_net The variable containing the total
#' number of cost for the year, default is `cost_total_net`
#'
#' @return The data with additional variables `apr_cost` to `mar_cost`
#' that assigns the cost to each month
#'
#' @seealso create_monthly_beddays
create_monthly_costs <- function(data,
                                 yearstay = yearstay,
                                 cost_total_net = cost_total_net) {
  check_variables_exist(data, c(
    "record_keydate1",
    "record_keydate2",
    paste0(tolower(month.abb[c(4L:12L, 1L:3L)]), "_beddays")
  ))

  beddays_months <- data %>%
    dplyr::select(dplyr::ends_with("_beddays")) %>%
    dplyr::rename_with(~ stringr::str_replace(., "_beddays", "_cost"))
  # Fix the instances where the episode is a daycase (in maternity data);
  # these will sometimes have 0.33 for the yearstay,
  # this should be applied to the relevant month.
  full_cost_col <- month.abb[c(4L:12L, 1L:3L)] %>%
    tolower() %>%
    paste0("_cost")

  daycase_cost_months <- data %>%
    dplyr::select(!dplyr::ends_with("_beddays")) %>%
    dplyr::mutate(
      daycase_added = tidyr::replace_na(
        ({{ yearstay }} == 0.33) | ({{ yearstay }} == 0L & {{ cost_total_net }} > 0.0),
        replace = FALSE
      )
    ) %>%
    dplyr::mutate(daycase_check = .data$daycase_added) %>%
    dplyr::mutate(cost_month = dplyr::if_else(
      .data$daycase_added,
      lubridate::month(.data$record_keydate1),
      NA
    )) %>%
    dplyr::mutate(
      cost_month = month.abb[.data$cost_month] %>%
        tolower() %>%
        paste0("_cost"),
      daycase_added = as.integer(.data$daycase_added)
    ) %>%
    tidyr::pivot_wider(
      names_from = "cost_month",
      values_from = "daycase_added",
      values_fill = 0L
    ) %>%
    dplyr::select(
      tidyselect::any_of(full_cost_col),
      "daycase_check"
    )

  available_months <- setdiff(names(daycase_cost_months), "daycase_check")
  add_months <- setdiff(full_cost_col, available_months)

  add_months_df <- dplyr::as_tibble(
    matrix(0.0, nrow = nrow(data), ncol = length(add_months)),
    .name_repair = ~add_months
  )

  daycase_cost_months <- daycase_cost_months %>%
    dplyr::bind_cols(add_months_df) %>%
    dplyr::select(c(
      dplyr::all_of(full_cost_col),
      "daycase_check"
    ))

  final_costs <- (daycase_cost_months[full_cost_col] + beddays_months) %>%
    dplyr::bind_cols(daycase_check = daycase_cost_months$daycase_check)

  data <- dplyr::bind_cols(data, final_costs) %>%
    dplyr::mutate(dplyr::across(
      dplyr::ends_with("_cost"),
      ~ dplyr::case_when(
        {{ cost_total_net }} == 0.0 ~ 0.0,
        .x != 0L ~ dplyr::if_else(
          daycase_check,
          {{ cost_total_net }},
          .x / {{ yearstay }} * {{ cost_total_net }}
        ),
        .default = 0.0
      )
    )) %>%
    dplyr::select(!"daycase_check")

  return(data)
}
