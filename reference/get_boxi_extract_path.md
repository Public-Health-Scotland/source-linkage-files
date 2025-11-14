# Get BOXI extract

Get the BOXI extract path for a given extract and year, returns an error
message if the extract does not exist

## Usage

``` r
get_boxi_extract_path(
  year,
  type = c("ae", "ae_cup", "acute", "acute_cup", "cmh", "deaths", "dn", "gp_ooh-c",
    "gp_ooh-d", "gp_ooh-o", "gp_ooh_cup", "homelessness", "maternity", "mh",
    "outpatients")
)
```

## Arguments

- year:

  Year of extract

- type:

  Name of BOXI extract

## Value

BOXI extracts containing data for each dataset

## See also

Other extract file paths:
[`get_hhg_path()`](https://public-health-scotland.github.io/source-linkage-files/reference/get_hhg_path.md),
[`get_it_deaths_path()`](https://public-health-scotland.github.io/source-linkage-files/reference/get_it_deaths_path.md),
[`get_it_ltc_path()`](https://public-health-scotland.github.io/source-linkage-files/reference/get_it_ltc_path.md),
[`get_it_prescribing_path()`](https://public-health-scotland.github.io/source-linkage-files/reference/get_it_prescribing_path.md),
[`get_source_extract_path()`](https://public-health-scotland.github.io/source-linkage-files/reference/get_source_extract_path.md),
[`get_sparra_path()`](https://public-health-scotland.github.io/source-linkage-files/reference/get_sparra_path.md)
