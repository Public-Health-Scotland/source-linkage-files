# Compute Age at Midpoint of Year

Compute the age of a client at the midpoint of the year - 30-09-YYYY

## Usage

``` r
compute_mid_year_age(fyyear, dob)
```

## Arguments

- fyyear:

  current financial year

- dob:

  date of birth of the clients

## Value

a vector of ages at the financial year midpoint

## See also

midpoint_fy

Other date functions:
[`calculate_stay()`](https://public-health-scotland.github.io/source-linkage-files/reference/calculate_stay.md),
[`convert_date_to_numeric()`](https://public-health-scotland.github.io/source-linkage-files/reference/convert_date_to_numeric.md),
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
dob <- as.Date(c("01-01-1990", "31-10-1997"), format = "%d-%m-%Y")
fyyear <- "1920"
compute_mid_year_age(fyyear, dob)
#> [1] 29 21
```
