# Calculate Measures for Testing

Produces measures used within testing extracts. Computes various
measures for the variables specified.

## Usage

``` r
calculate_measures(
  data,
  vars = NULL,
  measure = c("sum", "all", "min-max"),
  group_by = NULL
)
```

## Arguments

- data:

  A processed dataframe containing a summary of the mean and sum of
  variables.

- vars:

  Specify variables you want to test. This will match this e.g
  c(`beddays`, `cost`, `yearstay`). Default as NULL for summarising
  everything.

- measure:

  The measure you want to apply to variables

- group_by:

  Default as NULL for grouping variables. Specify variables for grouping
  e.g recid for episode file testing.

## Value

a tibble with a summary

## See also

produce_source_extract_tests

Other extract test functions:
[`produce_episode_file_ltc_tests()`](https://public-health-scotland.github.io/source-linkage-files/reference/produce_episode_file_ltc_tests.md),
[`produce_episode_file_tests()`](https://public-health-scotland.github.io/source-linkage-files/reference/produce_episode_file_tests.md),
[`produce_source_ch_tests()`](https://public-health-scotland.github.io/source-linkage-files/reference/produce_source_ch_tests.md),
[`produce_source_cmh_tests()`](https://public-health-scotland.github.io/source-linkage-files/reference/produce_source_cmh_tests.md),
[`produce_source_dn_tests()`](https://public-health-scotland.github.io/source-linkage-files/reference/produce_source_dn_tests.md),
[`produce_source_extract_tests()`](https://public-health-scotland.github.io/source-linkage-files/reference/produce_source_extract_tests.md),
[`produce_source_hc_tests()`](https://public-health-scotland.github.io/source-linkage-files/reference/produce_source_hc_tests.md),
[`produce_source_nrs_tests()`](https://public-health-scotland.github.io/source-linkage-files/reference/produce_source_nrs_tests.md)
