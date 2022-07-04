#' Assign costs for single day episodes
#'
#' @description Assign costs for single day episodes to the
#' relevant month using a cost vector
#'
#' @param data Data to assign costs for
#' @param date_var Date vector for the costs, e.g admission date or discharge date
#' @param cost_var Cost variable containing the costs e.g. cost_total_net
#'
#' @return The data with additional variables `apr_cost` to `mar_cost`
#' that assigns the cost to each month
#' @export
#'
create_day_episode_costs <- function(data, date_var, cost_var) {
  data <- data %>%
    # month and month_cost variable
    dplyr::mutate(month = strftime({{ date_var }}, "%m")) %>%
    dplyr::mutate(
      apr_cost = dplyr::if_else(.data$month == "04", {{ cost_var }}, 0),
      may_cost = dplyr::if_else(.data$month == "05", {{ cost_var }}, 0),
      jun_cost = dplyr::if_else(.data$month == "06", {{ cost_var }}, 0),
      jul_cost = dplyr::if_else(.data$month == "07", {{ cost_var }}, 0),
      aug_cost = dplyr::if_else(.data$month == "08", {{ cost_var }}, 0),
      sep_cost = dplyr::if_else(.data$month == "09", {{ cost_var }}, 0),
      oct_cost = dplyr::if_else(.data$month == "10", {{ cost_var }}, 0),
      nov_cost = dplyr::if_else(.data$month == "11", {{ cost_var }}, 0),
      dec_cost = dplyr::if_else(.data$month == "12", {{ cost_var }}, 0),
      jan_cost = dplyr::if_else(.data$month == "01", {{ cost_var }}, 0),
      feb_cost = dplyr::if_else(.data$month == "02", {{ cost_var }}, 0),
      mar_cost = dplyr::if_else(.data$month == "03", {{ cost_var }}, 0)
    )
}
