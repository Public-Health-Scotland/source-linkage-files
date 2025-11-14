# Create Health Board cost test flags

Create flags for each NHS Health Board with cost assigned if present in
that record.

## Usage

``` r
create_hb_cost_test_flags(data, hb_var, cost_var)
```

## Arguments

- data:

  the data containing a health board variable e.g. HB2019

- hb_var:

  Health board variable e.g. HB2019 HB2018 hbpraccode

- cost_var:

  Cost variable e.g. cost_total_net

## Value

a dataframe with flag (1 or 0) for each Health Board

## See also

Other flag functions:
[`create_demog_test_flags()`](https://public-health-scotland.github.io/source-linkage-files/reference/create_demog_test_flags.md),
[`create_hb_test_flags()`](https://public-health-scotland.github.io/source-linkage-files/reference/create_hb_test_flags.md),
[`create_hscp_test_flags()`](https://public-health-scotland.github.io/source-linkage-files/reference/create_hscp_test_flags.md),
[`create_lca_client_test_flags()`](https://public-health-scotland.github.io/source-linkage-files/reference/create_lca_client_test_flags.md),
[`create_lca_test_flags()`](https://public-health-scotland.github.io/source-linkage-files/reference/create_lca_test_flags.md),
[`create_sending_location_test_flags()`](https://public-health-scotland.github.io/source-linkage-files/reference/create_sending_location_test_flags.md)
