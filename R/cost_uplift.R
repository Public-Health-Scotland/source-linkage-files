#' Uplift costs
#'
#' @param data episode data
#' @param uplift
#'
#' @return episode data with uplifted costs
#' @export
cost_uplift <- function(data, uplift) {
  data <- data %>%
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
    )
  return(data)
}
