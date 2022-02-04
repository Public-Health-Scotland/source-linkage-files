monthly_cost_beddays <- function(data, uri_var, month_var, cost_var, beddays_var) {
  data %>%
    select({{ uri_var }}, {{ month_var }}, {{ cost_var }}, {{ beddays_var }}) %>%
    mutate(
      apr_cost = if_else({{ month_var }} == 4, {{ cost_var }}, 0),
      may_cost = if_else({{ month_var }} == 5, {{ cost_var }}, 0),
      jun_cost = if_else({{ month_var }} == 6, {{ cost_var }}, 0),
      jul_cost = if_else({{ month_var }} == 7, {{ cost_var }}, 0),
      aug_cost = if_else({{ month_var }} == 8, {{ cost_var }}, 0),
      sep_cost = if_else({{ month_var }} == 9, {{ cost_var }}, 0),
      oct_cost = if_else({{ month_var }} == 10, {{ cost_var }}, 0),
      nov_cost = if_else({{ month_var }} == 11, {{ cost_var }}, 0),
      dec_cost = if_else({{ month_var }} == 12, {{ cost_var }}, 0),
      jan_cost = if_else({{ month_var }} == 1, {{ cost_var }}, 0),
      feb_cost = if_else({{ month_var }} == 2, {{ cost_var }}, 0),
      mar_cost = if_else({{ month_var }} == 3, {{ cost_var }}, 0),
      apr_beddays = if_else({{ month_var }} == 4, {{ beddays_var }}, 0),
      may_beddays = if_else({{ month_var }} == 5, {{ beddays_var }}, 0),
      jun_beddays = if_else({{ month_var }} == 6, {{ beddays_var }}, 0),
      jul_beddays = if_else({{ month_var }} == 7, {{ beddays_var }}, 0),
      aug_beddays = if_else({{ month_var }} == 8, {{ beddays_var }}, 0),
      sep_beddays = if_else({{ month_var }} == 9, {{ beddays_var }}, 0),
      oct_beddays = if_else({{ month_var }} == 10, {{ beddays_var }}, 0),
      nov_beddays = if_else({{ month_var }} == 11, {{ beddays_var }}, 0),
      dec_beddays = if_else({{ month_var }} == 12, {{ beddays_var }}, 0),
      jan_beddays = if_else({{ month_var }} == 1, {{ beddays_var }}, 0),
      feb_beddays = if_else({{ month_var }} == 2, {{ beddays_var }}, 0),
      mar_beddays = if_else({{ month_var }} == 3, {{ beddays_var }}, 0)
    ) %>%
    group_by({{ uri_var }}) %>%
    summarise(across(contains(c("_cost", "_beddays")))) %>%
    ungroup()
}
