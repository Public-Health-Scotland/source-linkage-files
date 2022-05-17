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
}
