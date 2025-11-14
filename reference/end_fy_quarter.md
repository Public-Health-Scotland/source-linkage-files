# Return the end of a quarter

Get the end date of the specified FY quarter.

## Usage

``` r
end_fy_quarter(quarter)
```

## Arguments

- quarter:

  usually `period` from Social Care, or any character vector in the form
  `YYYYQX` where `X` is the quarter number

## Value

a vector of dates of the end of the FY quarter

## See also

Other date functions:
[`calculate_stay()`](https://public-health-scotland.github.io/source-linkage-files/reference/calculate_stay.md),
[`compute_mid_year_age()`](https://public-health-scotland.github.io/source-linkage-files/reference/compute_mid_year_age.md),
[`convert_date_to_numeric()`](https://public-health-scotland.github.io/source-linkage-files/reference/convert_date_to_numeric.md),
[`convert_numeric_to_date()`](https://public-health-scotland.github.io/source-linkage-files/reference/convert_numeric_to_date.md),
[`end_fy()`](https://public-health-scotland.github.io/source-linkage-files/reference/end_fy.md),
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
end_fy_quarter("2019Q1")
#> [1] "2019-06-30"
```
