# Return the date of the midpoint of the FY year

Get the date of the midpoint of the specified financial year

## Usage

``` r
midpoint_fy(year, format = c("fyyear", "alternate"))
```

## Arguments

- year:

  a character vector of years

- format:

  the format of the year vector, default is financial year

## Value

a vector of dates of the mid date of the FY year

## See also

Other date functions:
[`calculate_stay()`](https://public-health-scotland.github.io/source-linkage-files/reference/calculate_stay.md),
[`compute_mid_year_age()`](https://public-health-scotland.github.io/source-linkage-files/reference/compute_mid_year_age.md),
[`convert_date_to_numeric()`](https://public-health-scotland.github.io/source-linkage-files/reference/convert_date_to_numeric.md),
[`convert_numeric_to_date()`](https://public-health-scotland.github.io/source-linkage-files/reference/convert_numeric_to_date.md),
[`end_fy()`](https://public-health-scotland.github.io/source-linkage-files/reference/end_fy.md),
[`end_fy_quarter()`](https://public-health-scotland.github.io/source-linkage-files/reference/end_fy_quarter.md),
[`end_next_fy_quarter()`](https://public-health-scotland.github.io/source-linkage-files/reference/end_next_fy_quarter.md),
[`fy_interval()`](https://public-health-scotland.github.io/source-linkage-files/reference/fy_interval.md),
[`is_date_in_fyyear()`](https://public-health-scotland.github.io/source-linkage-files/reference/is_date_in_fyyear.md),
[`last_date_month()`](https://public-health-scotland.github.io/source-linkage-files/reference/last_date_month.md),
[`next_fy()`](https://public-health-scotland.github.io/source-linkage-files/reference/next_fy.md),
[`start_fy()`](https://public-health-scotland.github.io/source-linkage-files/reference/start_fy.md),
[`start_fy_quarter()`](https://public-health-scotland.github.io/source-linkage-files/reference/start_fy_quarter.md),
[`start_next_fy_quarter()`](https://public-health-scotland.github.io/source-linkage-files/reference/start_next_fy_quarter.md)

## Examples

``` r
midpoint_fy("1718")
#> [1] "2017-09-30"
```
