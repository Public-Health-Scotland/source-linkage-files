# Produce Social Care Episode Tests

Process social care datasets with distinct client counting

## Usage

``` r
produce_sc_episode_tests(
  data,
  sum_mean_vars = c("beddays", "cost", "yearstay"),
  max_min_vars = c("record_keydate1", "record_keydate2", "cost_total_net", "yearstay")
)
```

## Arguments

- data:

  new or old data for testing summary flags (data is from
  [`get_source_extract_path()`](https://public-health-scotland.github.io/source-linkage-files/reference/get_source_extract_path.md))

- sum_mean_vars:

  variables used when selecting 'all' measures from
  [`calculate_measures()`](https://public-health-scotland.github.io/source-linkage-files/reference/calculate_measures.md)

- max_min_vars:

  variables used when selecting 'min-max' from
  [`calculate_measures()`](https://public-health-scotland.github.io/source-linkage-files/reference/calculate_measures.md)

## Value

a dataframe with test measures for social care datasets

## See also

Other extract test functions:
[`calculate_measures()`](https://public-health-scotland.github.io/source-linkage-files/reference/calculate_measures.md),
[`produce_episode_file_ltc_tests()`](https://public-health-scotland.github.io/source-linkage-files/reference/produce_episode_file_ltc_tests.md),
[`produce_episode_file_tests()`](https://public-health-scotland.github.io/source-linkage-files/reference/produce_episode_file_tests.md),
[`produce_non_sc_episode_tests()`](https://public-health-scotland.github.io/source-linkage-files/reference/produce_non_sc_episode_tests.md),
[`produce_source_ch_tests()`](https://public-health-scotland.github.io/source-linkage-files/reference/produce_source_ch_tests.md),
[`produce_source_cmh_tests()`](https://public-health-scotland.github.io/source-linkage-files/reference/produce_source_cmh_tests.md),
[`produce_source_dn_tests()`](https://public-health-scotland.github.io/source-linkage-files/reference/produce_source_dn_tests.md),
[`produce_source_extract_tests()`](https://public-health-scotland.github.io/source-linkage-files/reference/produce_source_extract_tests.md),
[`produce_source_hc_tests()`](https://public-health-scotland.github.io/source-linkage-files/reference/produce_source_hc_tests.md),
[`produce_source_nrs_tests()`](https://public-health-scotland.github.io/source-linkage-files/reference/produce_source_nrs_tests.md)
