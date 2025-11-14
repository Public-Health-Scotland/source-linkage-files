# Assign costs for single day episodes

Assign costs for single day episodes to the relevant month using a cost
vector

## Usage

``` r
create_day_episode_costs(data, date_var, cost_var)
```

## Arguments

- data:

  Data to assign costs

- date_var:

  Date vector for the costs, e.g admission date or discharge date

- cost_var:

  Cost variable containing the costs e.g. cost_total_net

## Value

The data with additional variables `apr_cost` to `mar_cost` that assigns
the cost to each month
