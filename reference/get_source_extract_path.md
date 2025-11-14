# Source Extract File Path

Get the file path for Source Extract for given extract and year

## Usage

``` r
get_source_extract_path(
  year,
  type = c("acute", "ae", "at", "ch", "client", "cmh", "dd", "deaths", "dn", "gp_ooh",
    "hc", "homelessness", "maternity", "mh", "outpatients", "pis", "sds"),
  ...
)
```

## Arguments

- year:

  Year of extract

- type:

  Name of clean source extract

- ...:

  additional arguments passed to
  [`get_file_path()`](https://public-health-scotland.github.io/source-linkage-files/reference/get_file_path.md)

## Value

Path to clean source extract containing data for each dataset

## See also

Other extract file paths:
[`get_boxi_extract_path()`](https://public-health-scotland.github.io/source-linkage-files/reference/get_boxi_extract_path.md),
[`get_hhg_path()`](https://public-health-scotland.github.io/source-linkage-files/reference/get_hhg_path.md),
[`get_it_deaths_path()`](https://public-health-scotland.github.io/source-linkage-files/reference/get_it_deaths_path.md),
[`get_it_ltc_path()`](https://public-health-scotland.github.io/source-linkage-files/reference/get_it_ltc_path.md),
[`get_it_prescribing_path()`](https://public-health-scotland.github.io/source-linkage-files/reference/get_it_prescribing_path.md),
[`get_sparra_path()`](https://public-health-scotland.github.io/source-linkage-files/reference/get_sparra_path.md)
