# Create demographic test flags

Create the demographic flags for testing

## Usage

``` r
create_demog_test_flags(data)
```

## Arguments

- data:

  a dataframe containing demographic variables e.g. chi

## Value

a dataframe with flag (1 or 0) for each demographic variable. Missing
value flag from
[`is_missing()`](https://public-health-scotland.github.io/source-linkage-files/reference/is_missing.md)

## See also

Other flag functions:
[`create_hb_cost_test_flags()`](https://public-health-scotland.github.io/source-linkage-files/reference/create_hb_cost_test_flags.md),
[`create_hb_test_flags()`](https://public-health-scotland.github.io/source-linkage-files/reference/create_hb_test_flags.md),
[`create_hscp_test_flags()`](https://public-health-scotland.github.io/source-linkage-files/reference/create_hscp_test_flags.md),
[`create_lca_client_test_flags()`](https://public-health-scotland.github.io/source-linkage-files/reference/create_lca_client_test_flags.md),
[`create_lca_test_flags()`](https://public-health-scotland.github.io/source-linkage-files/reference/create_lca_test_flags.md),
[`create_sending_location_test_flags()`](https://public-health-scotland.github.io/source-linkage-files/reference/create_sending_location_test_flags.md)
