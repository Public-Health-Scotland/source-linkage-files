#' Generate costs for each month
#'
#' @param data Data to assign costs for
#' @param date_var Admission date or discharge date
#' @param cost_var Cost variable e.g. cost_total_net
#'
#' @return The data with additional variables `apr_cost` to `mar_cost`
#' that assigns cost to each month.
#'
#' @export
create_monthly_costs <- function(data, date_var, cost_var) {

data<- data %>%
  # month and month_cost variable
  mutate(month = strftime({{date_var}}, "%m")) %>%
  mutate(
    apr_cost = if_else(.data$month == "04", {{cost_var}}, 0),
    may_cost = if_else(.data$month == "05", {{cost_var}}, 0),
    jun_cost = if_else(.data$month == "06", {{cost_var}}, 0),
    jul_cost = if_else(.data$month == "07", {{cost_var}}, 0),
    aug_cost = if_else(.data$month == "08", {{cost_var}}, 0),
    sep_cost = if_else(.data$month == "09", {{cost_var}}, 0),
    oct_cost = if_else(.data$month == "10", {{cost_var}}, 0),
    nov_cost = if_else(.data$month == "11", {{cost_var}}, 0),
    dec_cost = if_else(.data$month == "12", {{cost_var}}, 0),
    jan_cost = if_else(.data$month == "01", {{cost_var}}, 0),
    feb_cost = if_else(.data$month == "02", {{cost_var}}, 0),
    mar_cost = if_else(.data$month == "03", {{cost_var}}, 0)
  )

}
