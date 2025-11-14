# Check if a date, or interval is in the financial year

Test to check if a date, or intervals is within a given financial year.
If given just one date it will check to see if it is in the given
financial year. When supplied with two dates it will check to see if any
part of that date range falls in the given financial year. If the
`date_end` is `NA` it checks that `date` was before or during the
financial year.

## Usage

``` r
is_date_in_fyyear(fyyear, date, date_end = NULL)
```

## Arguments

- fyyear:

  The financial year in the format '1718' as a character

- date:

  The main/start date to check

- date_end:

  (optional) The end date

## Value

a logical, TRUE/FALSE

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
[`last_date_month()`](https://public-health-scotland.github.io/source-linkage-files/reference/last_date_month.md),
[`midpoint_fy()`](https://public-health-scotland.github.io/source-linkage-files/reference/midpoint_fy.md),
[`next_fy()`](https://public-health-scotland.github.io/source-linkage-files/reference/next_fy.md),
[`start_fy()`](https://public-health-scotland.github.io/source-linkage-files/reference/start_fy.md),
[`start_fy_quarter()`](https://public-health-scotland.github.io/source-linkage-files/reference/start_fy_quarter.md),
[`start_next_fy_quarter()`](https://public-health-scotland.github.io/source-linkage-files/reference/start_next_fy_quarter.md)

## Examples

``` r
is_date_in_fyyear("2223", Sys.time())
#> [1] FALSE
is_date_in_fyyear(
  fyyear = "2122",
  date = as.Date("2020-01-01"),
  date_end = as.Date("2023-01-01")
)
#> [1] TRUE
```
