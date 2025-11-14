# Process Social Care SDS all episodes tests

This script takes the processed all SDS file and produces a test
comparison with the previous data.

## Usage

``` r
process_tests_sc_all_sds_episodes(data)
```

## Arguments

- data:

  The processed SDS all episode data produced by
  [`process_sc_all_sds()`](https://public-health-scotland.github.io/source-linkage-files/reference/process_sc_all_sds.md).

## Value

a [tibble](https://tibble.tidyverse.org/reference/tibble-package.html)
containing a test comparison.
