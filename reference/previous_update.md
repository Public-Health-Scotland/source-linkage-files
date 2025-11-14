# Previous update

Get the date of the previous update, e.g 'Mar_2022'

## Usage

``` r
previous_update(months_ago = 3L, override = NULL)
```

## Arguments

- months_ago:

  Number of months since the previous update the default is 3 i.e. one
  quarter ago.

- override:

  This allows specifying a specific update month if required.

## Value

previous update as MMM_YYYY

## See also

Other initialisation:
[`get_dd_period()`](https://public-health-scotland.github.io/source-linkage-files/reference/get_dd_period.md),
[`latest_cost_year()`](https://public-health-scotland.github.io/source-linkage-files/reference/latest_cost_year.md),
[`latest_update()`](https://public-health-scotland.github.io/source-linkage-files/reference/latest_update.md),
[`years_to_run()`](https://public-health-scotland.github.io/source-linkage-files/reference/years_to_run.md)

## Examples

``` r
previous_update() # Default 3 months
#> Jun_2025
previous_update(1) # 1 month ago
#> Aug_2025
previous_update(override = "May_2023") # Specific Month
#> [1] "May_2023"
```
