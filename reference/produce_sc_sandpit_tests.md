# Produce tests for social care sandpit extracts.

Produce tests for social care sandpit extracts.

## Usage

``` r
produce_sc_sandpit_tests(
  data,
  type = c("demographics", "client", "at", "ch", "hc", "sds")
)
```

## Arguments

- data:

  new or old data for testing summary flags (data is from
  [`get_sandpit_extract_path()`](https://public-health-scotland.github.io/source-linkage-files/reference/get_sandpit_extract_path.md))

- type:

  Name of sandpit extract.

## Value

a dataframe with a count of each flag from
[`calculate_measures()`](https://public-health-scotland.github.io/source-linkage-files/reference/calculate_measures.md)
