# Process Social Care, Care Home all episodes tests

This script takes the processed all Care Home file and produces a test
comparison with the previous data.

## Usage

``` r
process_tests_sc_all_ch_episodes(data)
```

## Arguments

- data:

  The processed Care Home all episode data produced by
  [`process_extract_care_home()`](https://public-health-scotland.github.io/source-linkage-files/reference/process_extract_care_home.md).

## Value

a [tibble](https://tibble.tidyverse.org/reference/tibble-package.html)
containing a test comparison.
