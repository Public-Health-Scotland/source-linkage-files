#' Convert monthly rows to variables
#'
#' @param data a dataframe containing cost and bed day variables
#' @param uri_var a unique variable for matching e.g. uri
#' @param month_num_var a variable containing month number e.g. costmonthnum
#' @param cost_var a variable containing cost information e.g. cost_total_net
#' @param beddays_var a variable containing beddays information e.g. yearstay
#'
#' @return A dataframe with monthly cost and bed day variables
#'
convert_monthly_rows_to_vars <- function(data, uri_var, month_num_var, cost_var, beddays_var) {

    data %>%
    dplyr::mutate(month_name = tolower(month.abb[{{ month_num_var }}])) %>%
    select(-{{ month_num_var }}) %>%
    dplyr::rename(cost = {{cost_var}},
           beddays = {{beddays_var}}) %>%
    tidyr::pivot_wider(
      names_from = .data$month_name,
      names_glue = "{month_name}_{.value}",
      values_from = c(.data$cost, .data$beddays),
      values_fill = 0.00
    )
}
