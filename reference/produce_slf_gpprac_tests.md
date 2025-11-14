# SLF GP Practice Lookup Tests

Produce the tests for the SLF GP Practice Lookup

## Usage

``` r
produce_slf_gpprac_tests(data)
```

## Arguments

- data:

  new or old data for testing summary flags (data is from
  [`get_slf_gpprac_path()`](https://public-health-scotland.github.io/source-linkage-files/reference/get_slf_gpprac_path.md))

## Value

a dataframe with a count of each flag from
[`calculate_measures()`](https://public-health-scotland.github.io/source-linkage-files/reference/calculate_measures.md)

## See also

[`create_hb_test_flags()`](https://public-health-scotland.github.io/source-linkage-files/reference/create_hb_test_flags.md)
and
[`create_hscp_test_flags()`](https://public-health-scotland.github.io/source-linkage-files/reference/create_hscp_test_flags.md)
for creating test flags

Other slf test functions:
[`produce_it_chi_deaths_tests()`](https://public-health-scotland.github.io/source-linkage-files/reference/produce_it_chi_deaths_tests.md),
[`produce_slf_homelessness_tests()`](https://public-health-scotland.github.io/source-linkage-files/reference/produce_slf_homelessness_tests.md),
[`produce_slf_postcode_tests()`](https://public-health-scotland.github.io/source-linkage-files/reference/produce_slf_postcode_tests.md)
