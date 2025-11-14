# Process PC (postcode) Lookup tests

This script takes the processed acute extract and produces a test
comparison with the previous data. This is written to disk as an xlsx.

## Usage

``` r
process_tests_lookup_pc(data, update = previous_update())
```

## Arguments

- data:

  a [tibble](https://tibble.tidyverse.org/reference/tibble-package.html)
  of the processed data extract.

- update:

  The update to compare the lookup to, defaults to
  [`previous_update()`](https://public-health-scotland.github.io/source-linkage-files/reference/previous_update.md).

## Value

a [tibble](https://tibble.tidyverse.org/reference/tibble-package.html)
containing a test comparison.
