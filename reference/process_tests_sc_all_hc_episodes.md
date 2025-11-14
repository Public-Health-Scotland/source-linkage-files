# Process Social Care Home Care all episodes tests

This script takes the processed all Home Care file and produces a test
comparison with the previous data.

## Usage

``` r
process_tests_sc_all_hc_episodes(data)
```

## Arguments

- data:

  The processed Home Care all episode data produced by
  [`process_sc_all_home_care()`](https://public-health-scotland.github.io/source-linkage-files/reference/process_sc_all_home_care.md).

## Value

a [tibble](https://tibble.tidyverse.org/reference/tibble-package.html)
containing a test comparison.
