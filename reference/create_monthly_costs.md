# Create Monthly Costs

Assign monthly costs using a cost variable and vector containing monthly
beddays.

## Usage

``` r
create_monthly_costs(
  data,
  yearstay = yearstay,
  cost_total_net = cost_total_net
)
```

## Arguments

- data:

  Data containing bedday variables, see
  [create_monthly_beddays](https://public-health-scotland.github.io/source-linkage-files/reference/create_monthly_beddays.md)
  to create

- yearstay:

  The variable containing the total number of beddays in the year,
  default is `yearstay`

- cost_total_net:

  The variable containing the total number of cost for the year, default
  is `cost_total_net`

## Value

The data with additional variables `apr_cost` to `mar_cost` that assigns
the cost to each month

## See also

create_monthly_beddays
