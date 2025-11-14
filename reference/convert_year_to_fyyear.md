# Convert year types - Alternate year form to financial year form

Convert a year vector from the alternate format '2017' to financial year
format '2017'.

## Usage

``` r
convert_year_to_fyyear(year)
```

## Arguments

- year:

  vector of years in the form '2017'

## Value

a vector of years in the normal financial year form '1718'

## See also

Other year functions:
[`check_year_format()`](https://public-health-scotland.github.io/source-linkage-files/reference/check_year_format.md),
[`convert_fyyear_to_year()`](https://public-health-scotland.github.io/source-linkage-files/reference/convert_fyyear_to_year.md)

## Examples

``` r
years <- c("2017", "2018")
convert_year_to_fyyear(years)
#> [1] "1718" "1819"
```
