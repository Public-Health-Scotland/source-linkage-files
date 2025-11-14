# Process tests for the social care sandpit extracts

Process tests for the social care sandpit extracts

## Usage

``` r
process_tests_sc_sandpit(
  type = c("at", "hc", "ch", "sds", "demographics", "client"),
  year = NULL
)
```

## Arguments

- type:

  Name of sandpit extract.

- year:

  Year of extract

## Value

a [tibble](https://tibble.tidyverse.org/reference/tibble-package.html)
containing a test comparison.
