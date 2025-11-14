# Check data exists for a year

Check there is data available for a given year as some extracts are year
dependent. E.g Homelessness is only available from 2016/17 onwards.

## Usage

``` r
check_year_valid(
  year,
  type = c("acute", "ae", "at", "ch", "client", "cmh", "cost_dna", "dd", "deaths", "dn",
    "gpooh", "hc", "homelessness", "hhg", "maternity", "mh", "nsu", "outpatients", "pis",
    "sds", "sparra")
)
```

## Arguments

- year:

  Financial year

- type:

  name of extract

## Value

A logical TRUE/FALSE
