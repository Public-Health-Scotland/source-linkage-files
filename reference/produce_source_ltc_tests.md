# LTC Episodes Tests

Produce the test for the Long Term Conditions (LTCs) all episodes

## Usage

``` r
produce_source_ltc_tests(data)
```

## Arguments

- data:

  new or old data for testing summary flags (data is from
  [`get_ltcs_path()`](https://public-health-scotland.github.io/source-linkage-files/reference/get_ltcs_path.md)

## Value

a dataframe with a count of each flag.

## See also

Other social care test functions:
[`produce_sc_all_episodes_tests()`](https://public-health-scotland.github.io/source-linkage-files/reference/produce_sc_all_episodes_tests.md),
[`produce_sc_demog_lookup_tests()`](https://public-health-scotland.github.io/source-linkage-files/reference/produce_sc_demog_lookup_tests.md),
[`produce_source_at_tests()`](https://public-health-scotland.github.io/source-linkage-files/reference/produce_source_at_tests.md),
[`produce_source_sds_tests()`](https://public-health-scotland.github.io/source-linkage-files/reference/produce_source_sds_tests.md),
[`produce_tests_sc_client_lookup()`](https://public-health-scotland.github.io/source-linkage-files/reference/produce_tests_sc_client_lookup.md)
