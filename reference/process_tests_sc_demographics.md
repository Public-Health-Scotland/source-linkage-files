# Process Social Care Demographics tests

Take the processed demographics extract and produces a test comparison
with the previous data.

## Usage

``` r
process_tests_sc_demographics(data)
```

## Arguments

- data:

  The processed demographic data produced by
  [`process_lookup_sc_demographics()`](https://public-health-scotland.github.io/source-linkage-files/reference/process_lookup_sc_demographics.md).

## Value

a [tibble](https://tibble.tidyverse.org/reference/tibble-package.html)
containing a test comparison.
