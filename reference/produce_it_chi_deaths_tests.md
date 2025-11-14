# CHI death tests

Produce the tests for IT CHI deaths

## Usage

``` r
produce_it_chi_deaths_tests(data)
```

## Arguments

- data:

  new or old data for testing summary flags (data is from
  [`get_slf_chi_deaths_path()`](https://public-health-scotland.github.io/source-linkage-files/reference/get_slf_chi_deaths_path.md))

## Value

a dataframe with a count of each flag from
[`calculate_measures()`](https://public-health-scotland.github.io/source-linkage-files/reference/calculate_measures.md)

## See also

Other slf test functions:
[`produce_slf_gpprac_tests()`](https://public-health-scotland.github.io/source-linkage-files/reference/produce_slf_gpprac_tests.md),
[`produce_slf_homelessness_tests()`](https://public-health-scotland.github.io/source-linkage-files/reference/produce_slf_homelessness_tests.md),
[`produce_slf_postcode_tests()`](https://public-health-scotland.github.io/source-linkage-files/reference/produce_slf_postcode_tests.md)
