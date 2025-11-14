# SLF Homelessness Extract Tests

Produce the tests for the SLF Homelessness Extract

## Usage

``` r
produce_slf_homelessness_tests(
  data,
  max_min_vars = c("record_keydate1", "record_keydate2")
)
```

## Arguments

- data:

  The data for testing

- max_min_vars:

  Shouldn't need to change, currently specifies `record_keydate1` and
  `record_keydate2`

## Value

a dataframe with a count of each flag from
[`calculate_measures()`](https://public-health-scotland.github.io/source-linkage-files/reference/calculate_measures.md)

## See also

Other slf test functions:
[`produce_it_chi_deaths_tests()`](https://public-health-scotland.github.io/source-linkage-files/reference/produce_it_chi_deaths_tests.md),
[`produce_slf_gpprac_tests()`](https://public-health-scotland.github.io/source-linkage-files/reference/produce_slf_gpprac_tests.md),
[`produce_slf_postcode_tests()`](https://public-health-scotland.github.io/source-linkage-files/reference/produce_slf_postcode_tests.md)
