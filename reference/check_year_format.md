# Check that the year is in the correct format

Test to check that the year vector is in the correct format

## Usage

``` r
check_year_format(year, format = "fyyear")
```

## Arguments

- year:

  the year to check

- format:

  the format that year should be using. Default is "fyyear" for example
  `1718`, the other format available is "alternate" e.g. `2017`

## Value

The year if the check passes, it will be converted to a character if not
already.

## See also

Other year functions:
[`convert_fyyear_to_year()`](https://public-health-scotland.github.io/source-linkage-files/reference/convert_fyyear_to_year.md),
[`convert_year_to_fyyear()`](https://public-health-scotland.github.io/source-linkage-files/reference/convert_year_to_fyyear.md)
