# Convert Monthly Rows to Variables

Creates data with monthly cost and beddays variables using assigned cost
vector.

## Usage

``` r
convert_monthly_rows_to_vars(data, month_num_var, cost_var, beddays_var)
```

## Arguments

- data:

  a dataframe containing cost and bed day variables

- month_num_var:

  a variable containing month number e.g. `cost_month_num`

- cost_var:

  a variable containing cost information e.g. `cost_total_net`

- beddays_var:

  a variable containing beddays information e.g. `yearstay`

## Value

A dataframe with monthly cost and bed day variables
