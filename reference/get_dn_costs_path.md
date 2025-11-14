# District Nursing Costs File Path

Get the full District Nursing costs lookup path

## Usage

``` r
get_dn_costs_path(..., update = NULL)
```

## Arguments

- ...:

  additional arguments passed to
  [`get_file_path()`](https://public-health-scotland.github.io/source-linkage-files/reference/get_file_path.md)

- update:

  passed through
  [`latest_update()`](https://public-health-scotland.github.io/source-linkage-files/reference/latest_update.md)

## Value

The path to the costs lookup as an
[`fs::path()`](https://fs.r-lib.org/reference/path.html)

## See also

[`get_file_path()`](https://public-health-scotland.github.io/source-linkage-files/reference/get_file_path.md)
for the generic function.

Other costs lookup file paths:
[`get_ch_costs_path()`](https://public-health-scotland.github.io/source-linkage-files/reference/get_ch_costs_path.md),
[`get_dn_raw_costs_path()`](https://public-health-scotland.github.io/source-linkage-files/reference/get_dn_raw_costs_path.md),
[`get_gp_ooh_costs_path()`](https://public-health-scotland.github.io/source-linkage-files/reference/get_gp_ooh_costs_path.md),
[`get_gp_ooh_raw_costs_path()`](https://public-health-scotland.github.io/source-linkage-files/reference/get_gp_ooh_raw_costs_path.md),
[`get_hc_costs_path()`](https://public-health-scotland.github.io/source-linkage-files/reference/get_hc_costs_path.md),
[`get_hc_raw_costs_path()`](https://public-health-scotland.github.io/source-linkage-files/reference/get_hc_raw_costs_path.md)
