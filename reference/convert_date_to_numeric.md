# Convert a date type to the 'SLF numeric format'

Convert a date to the 'SLF numeric format' - YYYYMMDD

## Usage

``` r
convert_date_to_numeric(date)
```

## Arguments

- date:

  a vector of dates

## Value

a vector of numerics where the number is of the form YYYYMMDD

## See also

Other date functions:
[`calculate_stay()`](https://public-health-scotland.github.io/source-linkage-files/reference/calculate_stay.md),
[`compute_mid_year_age()`](https://public-health-scotland.github.io/source-linkage-files/reference/compute_mid_year_age.md),
[`convert_numeric_to_date()`](https://public-health-scotland.github.io/source-linkage-files/reference/convert_numeric_to_date.md),
[`end_fy()`](https://public-health-scotland.github.io/source-linkage-files/reference/end_fy.md),
[`end_fy_quarter()`](https://public-health-scotland.github.io/source-linkage-files/reference/end_fy_quarter.md),
[`end_next_fy_quarter()`](https://public-health-scotland.github.io/source-linkage-files/reference/end_next_fy_quarter.md),
[`fy_interval()`](https://public-health-scotland.github.io/source-linkage-files/reference/fy_interval.md),
[`is_date_in_fyyear()`](https://public-health-scotland.github.io/source-linkage-files/reference/is_date_in_fyyear.md),
[`last_date_month()`](https://public-health-scotland.github.io/source-linkage-files/reference/last_date_month.md),
[`midpoint_fy()`](https://public-health-scotland.github.io/source-linkage-files/reference/midpoint_fy.md),
[`next_fy()`](https://public-health-scotland.github.io/source-linkage-files/reference/next_fy.md),
[`start_fy()`](https://public-health-scotland.github.io/source-linkage-files/reference/start_fy.md),
[`start_fy_quarter()`](https://public-health-scotland.github.io/source-linkage-files/reference/start_fy_quarter.md),
[`start_next_fy_quarter()`](https://public-health-scotland.github.io/source-linkage-files/reference/start_next_fy_quarter.md)

## Examples

``` r
convert_date_to_numeric(as.Date("2021-03-31"))
#> [1] 20210331
```
