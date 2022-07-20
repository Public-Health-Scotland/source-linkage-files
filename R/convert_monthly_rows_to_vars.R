#' Convert Monthly Rows to Variables
#'
#' @description Creates data with monthly cost and beddays variables using assigned cost vector
#'
#' @param data a dataframe containing cost and bed day variables
#' @param month_num_var a variable containing month number e.g. `cost_month_num`
#' @param cost_var a variable containing cost information e.g. `cost_total_net`
#' @param beddays_var a variable containing beddays information e.g. `yearstay`
#'
#' @return A dataframe with monthly cost and bed day variables
#'
convert_monthly_rows_to_vars <- function(data, month_num_var, cost_var, beddays_var) {
  month_order <- tolower(month.abb[c(4:12, 1:3)])

  data %>%
    dplyr::mutate(month_name = month_order[{{ month_num_var }}]) %>%
    dplyr::select(-{{ month_num_var }}) %>%
    dplyr::rename(
      cost = {{ cost_var }},
      beddays = {{ beddays_var }}
    ) %>%
    tidyr::pivot_wider(
      names_from = .data$month_name,
      names_glue = "{month_name}_{.value}",
      values_from = c(.data$cost, .data$beddays),
      values_fill = 0.00
    ) %>%
    dplyr::select(
      !dplyr::ends_with(c("_beddays", "_cost")),
      glue::glue("{month_order}_beddays"),
      glue::glue("{month_order}_cost")
    )
}
