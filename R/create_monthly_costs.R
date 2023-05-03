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
#' @export
#' @seealso create_monthly_beddays
create_monthly_costs <- function(data,
                                 yearstay = yearstay,
                                 cost_total_net = cost_total_net) {
  check_variables_exist(data, c(
    "record_keydate1",
    "record_keydate2",
    paste0(tolower(month.abb[c(4:12, 1:3)]), "_beddays")
  ))

  costs <- data %>%
    dplyr::select(dplyr::ends_with("_beddays")) %>%
    dplyr::rename_with(~ stringr::str_replace(., "_beddays", "_cost"))
  # Fix the instances where the episode is a daycase;
  # these will sometimes have 0.33 for the yearstay,
  # this should be applied to the relevant month.
  costs_daycase <- data %>%
    dplyr::select(!dplyr::ends_with("_beddays")) %>%
    dplyr::mutate(
      daycase_added = (.data$record_keydate1 == .data$record_keydate2)
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
      daycase_added = dplyr::if_else(.data$daycase_added, 1, 0)
    ) %>%
    tidyr::pivot_wider(
      names_from = "cost_month",
      values_from = "daycase_added",
      values_fill = 0
    ) %>%
    dplyr::select(
      tidyselect::any_of(
        month.abb[c(4:12, 1:3)] %>%
          tolower() %>%
          paste0("_cost")
      ),
      "daycase_check"
    )

  avaliable_months <- setdiff(names(costs_daycase), "daycase_check")

  costs <- (costs_daycase[avaliable_months] + costs[avaliable_months]) %>%
    dplyr::bind_cols(daycase_check = costs_daycase$daycase_check)

  data <- dplyr::bind_cols(data, costs) %>%
    dplyr::mutate(dplyr::across(
      dplyr::ends_with("_cost"),
      ~ dplyr::case_when(
        {{ cost_total_net }} == 0.0 ~ 0.0,
        .x != 0L ~ dplyr::if_else(
          daycase_check,
          {{ cost_total_net }},
          .x / yearstay * {{ cost_total_net }}
        ),
        .default = 0.0
      )
    )) %>%
    dplyr::select(!"daycase_check")

  return(data)
}
