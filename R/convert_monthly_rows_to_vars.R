#' Convert monthly rows to variables
#'
#' @param data a dataframe containing cost and bed day variables
#' @param uri_var a unique variable for matching e.g. uri
#' @param month_var a variable containing month number e.g. costmonthnum
#' @param cost_var a variable containing cost information e.g. cost_total_net
#' @param beddays_var a variable containing beddays information e.g. yearstay
#'
#' @return
#' @importFrom dplyr tidyr
convert_monthly_rows_to_vars <- function(data, uri_var, month_var, cost_var, beddays_var){

    data %>%
    select({{ uri_var }}, {{ cost_var }}, {{ beddays_var }}, {{ month_var }}) %>%
    mutate(month_name = tolower(month.abb[{{ month_var }}])) %>%
    rename(cost = {{cost_var}},
           beddays = {{beddays_var}}) %>%
    pivot_wider(
      names_from = month_name,
      names_glue = "{month_name}_{.value}",
      values_from = c(cost, beddays),
      values_fill = 0
    ) %>%
  group_by({{ uri_var }}) %>%
    summarise(across(contains(c("_cost", "_beddays")))) %>%
    ungroup()
}
