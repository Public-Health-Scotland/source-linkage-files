# Source District Nursing Tests

Produce a set of tests which can be used by most of the extracts. This
will produce counts of various demographics using
[`create_demog_test_flags()`](https://public-health-scotland.github.io/source-linkage-files/reference/create_demog_test_flags.md)
counts of episodes for every `hbtreatcode` using
[`create_hb_test_flags()`](https://public-health-scotland.github.io/source-linkage-files/reference/create_hb_test_flags.md),
a total cost for each `hbtreatcode` using
[`create_hb_cost_test_flags()`](https://public-health-scotland.github.io/source-linkage-files/reference/create_hb_cost_test_flags.md).
It will also produce various summary statistics for bedday, cost and
episode date variables.

## Usage

``` r
produce_source_dn_tests(
  data,
  sum_mean_vars = c("cost", "yearstay"),
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

a dataframe with a count of each flag from
[`calculate_measures()`](https://public-health-scotland.github.io/source-linkage-files/reference/calculate_measures.md)

## See also

[`create_hb_test_flags()`](https://public-health-scotland.github.io/source-linkage-files/reference/create_hb_test_flags.md),
[`create_hscp_test_flags()`](https://public-health-scotland.github.io/source-linkage-files/reference/create_hscp_test_flags.md)
and
[`create_hb_cost_test_flags()`](https://public-health-scotland.github.io/source-linkage-files/reference/create_hb_cost_test_flags.md)
for creating test flags.

calculate_measures

Other extract test functions:
[`calculate_measures()`](https://public-health-scotland.github.io/source-linkage-files/reference/calculate_measures.md),
[`produce_episode_file_ltc_tests()`](https://public-health-scotland.github.io/source-linkage-files/reference/produce_episode_file_ltc_tests.md),
[`produce_episode_file_tests()`](https://public-health-scotland.github.io/source-linkage-files/reference/produce_episode_file_tests.md),
[`produce_non_sc_episode_tests()`](https://public-health-scotland.github.io/source-linkage-files/reference/produce_non_sc_episode_tests.md),
[`produce_sc_episode_tests()`](https://public-health-scotland.github.io/source-linkage-files/reference/produce_sc_episode_tests.md),
[`produce_source_ch_tests()`](https://public-health-scotland.github.io/source-linkage-files/reference/produce_source_ch_tests.md),
[`produce_source_cmh_tests()`](https://public-health-scotland.github.io/source-linkage-files/reference/produce_source_cmh_tests.md),
[`produce_source_extract_tests()`](https://public-health-scotland.github.io/source-linkage-files/reference/produce_source_extract_tests.md),
[`produce_source_hc_tests()`](https://public-health-scotland.github.io/source-linkage-files/reference/produce_source_hc_tests.md),
[`produce_source_nrs_tests()`](https://public-health-scotland.github.io/source-linkage-files/reference/produce_source_nrs_tests.md)
