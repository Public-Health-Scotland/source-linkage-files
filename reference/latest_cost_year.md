# The latest financial year for Cost uplift setting

Get the latest year for cost uplift latest_cost_year() is hard coded in
cost_uplift(). 2223 is not changed automatically with time passes. It is
changed only when we get a new instruction from somewhere about cost
uplift. Do not change unless specific instructions. Changing this means
that we need to change cost_uplift().

## Usage

``` r
latest_cost_year()
```

## Value

The financial year format

## See also

Other initialisation:
[`get_dd_period()`](https://public-health-scotland.github.io/source-linkage-files/reference/get_dd_period.md),
[`latest_update()`](https://public-health-scotland.github.io/source-linkage-files/reference/latest_update.md),
[`previous_update()`](https://public-health-scotland.github.io/source-linkage-files/reference/previous_update.md),
[`years_to_run()`](https://public-health-scotland.github.io/source-linkage-files/reference/years_to_run.md)
