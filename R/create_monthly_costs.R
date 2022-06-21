#' Create monthly costs
#'
#' @description Assign monthly costs using a cost variable and vector containing monthly beddays
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
create_monthly_costs <- function(data, yearstay = yearstay, cost_total_net = cost_total_net) {
  costs <- data %>%
    dplyr::select(dplyr::ends_with("_beddays")) %>%
    dplyr::rename_with(~ stringr::str_replace(., "_beddays", "_costs"))

  data <- dplyr::bind_cols(data, costs) %>%
    dplyr::mutate(dplyr::across(dplyr::ends_with("_costs"), ~ dplyr::if_else(.x != 0, .x / {{ yearstay }} * {{ cost_total_net }}, 0)))

  return(data)
}
