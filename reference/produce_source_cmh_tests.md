# Source Extract Tests

Produce a set of tests which can be used by the CMH extract

This will produce counts of various demographics. It will also produce
various summary statistics for episode date variables.

## Usage

``` r
produce_source_cmh_tests(data)
```

## Arguments

- data:

  new or old data for testing summary flags (data is from
  [`get_source_extract_path()`](https://public-health-scotland.github.io/source-linkage-files/reference/get_source_extract_path.md))

## Value

a dataframe with a count of each flag from
[`calculate_measures()`](https://public-health-scotland.github.io/source-linkage-files/reference/calculate_measures.md)

## See also

[`calculate_measures()`](https://public-health-scotland.github.io/source-linkage-files/reference/calculate_measures.md)

Other extract test functions:
[`calculate_measures()`](https://public-health-scotland.github.io/source-linkage-files/reference/calculate_measures.md),
[`produce_episode_file_ltc_tests()`](https://public-health-scotland.github.io/source-linkage-files/reference/produce_episode_file_ltc_tests.md),
[`produce_episode_file_tests()`](https://public-health-scotland.github.io/source-linkage-files/reference/produce_episode_file_tests.md),
[`produce_source_ch_tests()`](https://public-health-scotland.github.io/source-linkage-files/reference/produce_source_ch_tests.md),
[`produce_source_dn_tests()`](https://public-health-scotland.github.io/source-linkage-files/reference/produce_source_dn_tests.md),
[`produce_source_extract_tests()`](https://public-health-scotland.github.io/source-linkage-files/reference/produce_source_extract_tests.md),
[`produce_source_hc_tests()`](https://public-health-scotland.github.io/source-linkage-files/reference/produce_source_hc_tests.md),
[`produce_source_nrs_tests()`](https://public-health-scotland.github.io/source-linkage-files/reference/produce_source_nrs_tests.md)
