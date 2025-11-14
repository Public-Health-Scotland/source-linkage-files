# Convert year types - Financial year form to the alternate form

Convert a year vector from financial year '1718' to the alternate format
'2017'.

## Usage

``` r
convert_fyyear_to_year(fyyear)
```

## Arguments

- fyyear:

  vector of financial years in the form '1718'

## Value

a vector of years in the alternate form '2017'

## See also

Other year functions:
[`check_year_format()`](https://public-health-scotland.github.io/source-linkage-files/reference/check_year_format.md),
[`convert_year_to_fyyear()`](https://public-health-scotland.github.io/source-linkage-files/reference/convert_year_to_fyyear.md)

## Examples

``` r
fyyears <- c("1718", "1819")
convert_fyyear_to_year(fyyears)
#> [1] "2017" "2018"
```
