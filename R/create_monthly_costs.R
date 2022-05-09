<<<<<<< HEAD
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

=======
#' Create monthly costs
#'
#' @param data Data containing bedday variables,
#' likely created by [create_monthly_beddays]
#' @param yearstay The variable containing the total
#' number of beddays in the year, default is `yearstay`
#' @param cost_total_net The variable containing the total
#' number of cost for the year, default is `cost_total_net`
#'
#' @return a [tibble][tibble::tibble-package] with cost variables
#' added
#' @export
#' @seealso create_monthly_beddays
create_monthly_costs <- function(data, yearstay = yearstay, cost_total_net = cost_total_net) {
  costs <- data %>%
    dplyr::select(dplyr::ends_with("_beddays")) %>%
    dplyr::rename_with(~ stringr::str_replace(., "_beddays", "_costs"))

  data <- dplyr::bind_cols(data, costs) %>%
    dplyr::mutate(dplyr::across(dplyr::ends_with("_costs"), ~ dplyr::if_else(.x != 0, .x / {{ yearstay }} * {{ cost_total_net }}, 0)))

  return(data)
>>>>>>> 0eae2cc164cded68b27cbc56bb48a0a70c6ab9e0
}
