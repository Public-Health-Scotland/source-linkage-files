# Process Social Care Alarms Telecare all episodes tests

This script takes the processed all Alarms Telecare file and produces a
test comparison with the previous data.

## Usage

``` r
process_tests_sc_all_at_episodes(data)
```

## Arguments

- data:

  The processed Alarms Telecare all episode data produced by
  [`process_sc_all_alarms_telecare()`](https://public-health-scotland.github.io/source-linkage-files/reference/process_sc_all_alarms_telecare.md).

## Value

a [tibble](https://tibble.tidyverse.org/reference/tibble-package.html)
containing a test comparison.
