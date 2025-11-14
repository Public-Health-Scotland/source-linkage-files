# Source Extract Tests

Produce a set of tests which can be used by most of the extracts. This
will produce counts of various demographics using
[`create_demog_test_flags()`](https://public-health-scotland.github.io/source-linkage-files/reference/create_demog_test_flags.md)
counts of episodes for every `hbrescode` using
[`create_hb_test_flags()`](https://public-health-scotland.github.io/source-linkage-files/reference/create_hb_test_flags.md),
a total cost for each `hbrescode` using
[`create_hb_cost_test_flags()`](https://public-health-scotland.github.io/source-linkage-files/reference/create_hb_cost_test_flags.md).
It will also produce various summary statistics for bedday, cost and
episode date variables.

## Usage

``` r
produce_individual_file_tests(data)
```

## Arguments

- data:

  new or old data for testing summary flags (data is from
  [`get_source_extract_path()`](https://public-health-scotland.github.io/source-linkage-files/reference/get_source_extract_path.md))

## Value

a dataframe with a count of each flag from
[`calculate_measures()`](https://public-health-scotland.github.io/source-linkage-files/reference/calculate_measures.md)
